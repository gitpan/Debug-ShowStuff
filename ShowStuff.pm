package Debug::ShowStuff;
use strict;
use Carp;
use vars qw[$VERSION $out $forceplain];

# default $out to STDOUT
$out = *STDOUT;

# version
$VERSION = '1.00';

# constants
use constant STDTABLE => "<P>\n<TABLE BORDER=4 RULES=ROWS CELLSPACING=0 CELLPADDING=3>\n";


#---------------------------------------------------------------------
# export
# 
use vars qw[@EXPORT_OK %EXPORT_TAGS @ISA];
use Exporter;
push @ISA, 'Exporter';

@EXPORT_OK = qw[
	showhash showhashhtml showhashplain
	showarray showarr
	showarraydiv showarrdiv
	showcgi
	showscalar showsca
	showref 
	showstderr
	setoutput
	pressenter
	inweb
	httpheader
	httpheaders
	println
	dieln
	nullfix
	diearr
	];

%EXPORT_TAGS = ('all' => [@EXPORT_OK]);
# 
# export
#---------------------------------------------------------------------


#===================================================================================================
# opening POD
# 

=head1 NAME

Debug::ShowStuff - A collection of handy debugging routines for displaying
the values of variables with a minimum of coding.

=head1 SYNOPSIS

	use Debug::ShowStuff ':all';
	
	# display values of a hash or hash reference
	showhash %hash;
	showhash $hashref;

	# display values of an array or array reference
	showarr @arr;
	showarr $arrref;
	
	# show all nested structures
	showref $reference
	
	# show all the params received through CGI
	showcgi();
	
	# A particularly fancy utility: display STDERR at top of web page
	my $warnings = showstderr;


=head1 INSTALLATION

C<Debug::ShowStuff> can be installed with the usual routine:

	perl Makefile.PL
	make
	make test
	make install

You can also just copy ShowStuff.pm into the Dev/ directory of one of your library trees.

=head1 DESCRIPTION

C<Debug::ShowStuff> grew dynamically from my needs in debugging code.  I found 
myself doing the same tasks over and over... displaying the keys and
values in a hash, displaying the elements in an array, displaying the output
of STDERR in a web page, etc.  C<Debug::ShowStuff> 
began as two or three of my favorite routines and grew as I added to that 
collection.  Finally I decided to publish these tools in the hope that others
will find them useful.

C<Debug::ShowStuff> is intended for debugging, not for production work.  I would
discourage anyone from using C<Debug::ShowStuff> in ready-for-primetime code.  
C<Debug::ShowStuff> is only for quick-n-dirty displays of variable values in order
to debug your code.

These functions display values that I personally like them displayed, but your
preferences may be different.  I encourage you to modify C<Debug::ShowStuff> to
suit your own needs.  

=head1 TEXT MODE and WEB MODE

The functions in C<Debug::ShowStuff> are designed to output either in plain text
mode (like if you're running the script from a command prompt, or in web mode
(like for a CGI).  If the script appears to be running in a CGI or other 
web mode (see the C<inweb> function) then values are output using HTML, with
special HTML characters escaped for proper display.  Othewise the values are
output as they are.

Generally you won't need to bother telling the routines C<Debug::ShowStuff> 
which way to display stuff... it figures it out on its own.

=head1 DYNAMIC OUTPUT and RETURN

The functions that start with "show" dynamically either output to STDOUT or
STDERR, or return a string to a variable, depending on the context in which the
functions are called.  For example, if you call showhash in a void context:

  showhash %myhash;

then the contents of %myhash are output to STDOUT.  On the other hand, if the
function is called in scalar context:

  my $var = showhash(%myhash);

then the same string that would have been output to STDOUT is instead
returned and stored in $var.  If the function is called in list context:

  my @arr = showhash(%myhash);

then the array is assigned a single element that consists of the entire
string that should be output.

=head1 FUNCTION DESCRIPTIONS

=cut

# 
# opening POD
#===================================================================================================


#===================================================================================================
# htmlesc
# 
# Private sub.  Formats a string for literal output in HTML.  An undefined
# first argument is returned as an empty string.
# 
sub htmlesc {
	my ($rv) = @_;
	return '' unless defined($rv);
	$rv =~ s|&|&#38;|g;
	$rv =~ s|"|&#34;|g;
	$rv =~ s|'|&#39;|g;
	$rv =~ s|<|&#60;|g;
	$rv =~ s|>|&#62;|g;
	return $rv;
}
# 
# htmlesc
#===================================================================================================



#===================================================================================================
# showhash
# 

=head1 showhash

Displays the keys and values in a hash.  Input is either a single hash reference or a regular hash.
If it looks like the sub is being called in a web environment (as indicated by the inweb function)
then the hash is displayed using HTML.  Otherwise the hash is displayed using plain text.

=cut

sub showhash {
	# HTML
	if (inweb())
		{return showhashhtml(@_)}

	# plain text
	else
		{return showhashplain(@_)}

}
# 
# showhash
#===================================================================================================


#===================================================================================================
# showhashhtml
# 
# Private sub. Displays the keys and values in a hash, formatted for HTML.
# 
sub showhashhtml {

my %myhash;
my $maxkey = 0;
my $maxval = 0;
my $fh = getfh(wantarray);

# print $fh "<P>\n<TABLE BORDER=4 RULES=ROWS CELLSPACING=0 CELLPADDING=3>\n";
print $fh STDTABLE;

# special case: only one element and it's undefined
if ( (@_ == 1) && (! defined($_[0])) ) {
	print $fh "<TR><TD>Only element input and it was undefined</TD></TR></TABLE>\n";
	return;
}

if (ref $_[0])
	{%myhash = %{$_[0]}}
else
	{%myhash = @_}

if (ref($_[0])) {
	my $title;
	
	if ($_[1])
		{$title = $_[1]}
	else
		{$title = $_[0]}

	print $fh "<TR><TH COLSPAN=3>", htmlesc($title), "</TH></TR>\n"
}

print $fh <<"(TABLETOP2)";
<TR BGCOLOR=NAVY>
<TH STYLE="background-color:navy;color:white">key</TH>
<TD>&nbsp;&nbsp;&nbsp;</TD>
<TH STYLE="background-color:navy;color:white">value</TH>
</TR>
(TABLETOP2)

foreach my $key (sort(keys(%myhash)))
	{print $fh '<TR><TD>', htmlesc($key), '</TD><TD></TD><TD>', htmlesc($myhash{$key}), "</TD></TR>\n"}

print $fh "</TABLE>\n<P>\n";

ref($fh) and return $fh->mem;
return '';
}
# 
# showhashhtml
#===================================================================================================


#===================================================================================================
# showhashplain
# 
# Private sub. Displays the keys and values in a hash, formatted using plain text.
# 
sub showhashplain {
	my %myhash;
	my $maxkey = 0;
	my $maxval = 0;
	my $fh = getfh(wantarray);
	
	print $fh "---------------------------------------\n";
	
	# special case: only one element and it's undefined
	if ( (@_ == 1) && (! defined($_[0])) ) {
		print
			"Only element input and it was undefined\n",
			"---------------------------------------\n\n";
		return;
	}

	if (ref($_[0]))
		{%myhash = %{$_[0]}}
	else
		{%myhash = @_}
	
	foreach my $key (sort(keys(%myhash))) {
		my $value = $myhash{$key};
		print $fh $key, ' = ', (defined($value) ? $value : '[undef]'), "\n";
	}

	print $fh "---------------------------------------\n\n";
	
	ref($fh) and return $fh->mem;
	return '';
}
# 
# showhashplain
#===================================================================================================


#===================================================================================================
# showarray
# 

=head1 showarray

Displays the values of an array.  Each element is displayed in a table row (in web mode) or
on a separate line (in plain text mode).  Undefined elements are displayed as the
string C<[undef]>.

If C<showarray> receives exactly one argument, and if that item is an array reference,
then the routine assumes that you want to display the elements in the referenced array.
Therefore, the following blocks of code display the same thing:

   showarray @myarr;
   showarray \@myarr;

=cut

sub showarray {
	my (@arr) = @_;
	my $fh = getfh(wantarray);
	
	# if first and only element is an array ref, use that as full array
	if ( (@arr == 1) && UNIVERSAL::isa($arr[0], 'ARRAY') )
		{@arr = @{$arr[0]}}
	
	#------------------------------------------------------
	# HTML
	#
	if (inweb()) {
		print $fh 
			"<P>\n<TABLE BORDER=4 RULES=ROWS CELLSPACING=0 CELLPADDING=3>\n",
			"<TR><TH BGCOLOR=\"#AAAAFF\">array</TH></TR>";
		
		foreach my $el (@arr)
			{print $fh '<TR><TD>', htmlesc($el), "</TD></TR>\n"}
		
		print $fh "</TABLE>\n<P>\n";
	}
	#
	# HTML
	#------------------------------------------------------
	
	
	#------------------------------------------------------
	# text
	#
	else {
		my $line = "------------------------------------\n";
		my ($firstdone);
		
		print $fh $line;
		
		foreach my $el (@arr){
			if (defined $el)
				{print $fh $el, "\n"}
			else
				{print $fh "[undef]\n"}
			
			$firstdone = 1;
		}
		
		if (! $firstdone)
			{print $fh "[empty array]\n", $line}
		else
			{print $fh $line}
	}
	#
	# text
	#------------------------------------------------------
	
	ref($fh) and return $fh->mem();
}

sub showarr{showarray(@_)}
# 
# showarray
#===================================================================================================


#===================================================================================================
# showarrdiv
# 

=head1 showarraydiv

Works just like C<showarray>, except that in text mode displays a solid line between
each element of the array.

=cut

sub showarraydiv {
	my (@arr) = @_;
	my $fh = getfh(wantarray);
	
	if ( (@arr == 1) && UNIVERSAL::isa($arr[0], 'ARRAY') )
		{@arr = @{$arr[0]}}
	
	#------------------------------------------------------
	# HTML
	#
	if ($ENV{'SCRIPT_NAME'}) {
		print $fh 
			"<P>\n<TABLE BORDER=4 RULES=ROWS CELLSPACING=0 CELLPADDING=3>\n",
			"<TR><TH BGCOLOR=\"#AAAAFF\">array</TH></TR>";
		
		foreach my $el (@arr)
			{print $fh '<TR><TD>', htmlesc($el), "</TD></TR>\n"}
		
		print $fh "</TABLE>\n<P>\n";
	}
	#
	# HTML
	#------------------------------------------------------
	
	
	#------------------------------------------------------
	# text
	#
	else {
		my $line = "------------------------------------\n";
		my ($firstdone);
		
		print $fh $line;
		
		foreach my $el (@arr){
			if (defined $el)
				{print $fh $el, "\n"}
			else
				{print $fh "[undef]\n"}
			
			print $fh $line;
			$firstdone = 1;
		}
		
		if (! $firstdone)
			{print $fh "[empty array]\n", $line}
	}
	#
	# text
	#------------------------------------------------------
	
	ref($fh) and return $fh->mem();
}

sub showarrdiv{showarraydiv(@_)}
# 
# showarraydiv
#===================================================================================================



#===================================================================================================
# showscalar
# 

=head1 showscalar

Outputs the value of a scalar.  The name is slightly innaccurate: you can input an array.
The array will be joined together to form a single scalar.

=cut

sub showscalar {
	my (@arr) = @_;
	my $fh = getfh(wantarray);
	

	#------------------------------------------------------
	# HTML
	# 
	if (inweb()) {
		print $fh 
			"<P>\n<TABLE BORDER=4 RULES=ROWS CELLSPACING=0 CELLPADDING=3>\n",
			"<TR><TH BGCOLOR=\"#AAAAFF\">scalar</TH></TR><TR><TD><PRE>";
		
		foreach my $el (@arr)
			{print $fh htmlesc($el)}
		
		print $fh "</PRE></TD></TR></TABLE>\n<P>\n";
	}
	#
	# HTML
	#------------------------------------------------------
	
	
	#------------------------------------------------------
	# text
	#
	else {
		print $fh "------------------------------------\n";
		
		if (@arr)
			{print $fh join('', map {defined($_) ? $_ : '[undef]'} sort({(defined($a) ? $a : '') cmp (defined($b) ? $b : '')} @arr)), "\n"}
		else
			{print $fh "[no elements]\n"}
		
		print $fh "------------------------------------\n";
	}
	#
	# text
	#------------------------------------------------------
	
	ref($fh) and return $fh->mem();
}

sub showsca{showscalar(@_)}
# 
# showscalar
#===================================================================================================


#===================================================================================================
# showcgi
# 

=head1 showcgi

Displays the CGI parameter keys and values.  This sub always outputs HTML.  

The optional parameter C<q>, may be a CGI query object:

   my $query = CGI->new();
   showcgi q => $query;

If C<q> is not sent, then a CGI object is created on the fly.

If the optional parameter C<skipempty> is true:

   showcgi skipempty => 1;

then CGI params that are empty (i.e. do not have
at least one non-space character) are not displayed.

=cut

sub showcgi {
my (%opts) = @_;
my (@keys, $fh, $q, $skipempty);

$q = $opts{'q'} || CGI->new();
$skipempty = $opts{'skipempty'};

@keys = sort $q->param;
$fh = getfh(wantarray);

print $fh STDTABLE;

# special case: no elements
if (! @keys) {
	print $fh "<TR><TD>No params</TD></TR></TABLE>\n";
	return;
}

print $fh <<"(TABLETOP2)";
<TR BGCOLOR=NAVY>
<TH STYLE="color:white">key</TH>
<TD>&nbsp;&nbsp;&nbsp;</TD>
<TH STYLE="color:white">value</TH>
</TR>
(TABLETOP2)

PARAMLOOP:
foreach my $key (@keys){
	my @vals = $q->param($key);
	
	if ($skipempty && @vals <= 1) {
		my $val = $vals[0];
		
		if ( (! defined $val) || ($val !~ m|\S|) )
			{next PARAMLOOP}
	}
	
	print $fh 
		'<TR VALIGN="top"><TD>',
		htmlesc($key),
		'</TD><TD></TD><TD>';
	
	if (@vals > 1) {
		print $fh STDTABLE;
		
		foreach my $val (@vals) {
			print $fh
				'<TR><TD>',
				htmlesc($val),
				"</TD></TR>\n";
		}
		
		print "</TABLE>\n";
	}
	
	else {
		print $fh
			htmlesc($vals[0]);
	}
	
	print $fh "</TD></TR>\n";
}

print $fh "</TABLE>\n<P>\n";

ref($fh) and return $fh->mem;
return '';
}
# 
# showcgi
#===================================================================================================


#===================================================================================================
# showref
# 

=head1 showref($ref, %options)

Displays a hash, array, or scalar references, treeing down through other references it contains.  
So, for example, the following code:

 my $ob = {
    name    => 'Raha',
    email   => 'raha@idocs.com',
    friends => [
       'Shalom',
       'Joe',
       'Furocha',
       ],
    };
    
 showref $ob;

produces the following output:

   /-----------------------------------------------------------\
   friends =
      ARRAY
         Shalom
         Joe
         Furocha
   email = raha@idocs.com
   name = Raha
   \-----------------------------------------------------------/

The values of the hash or arrays being referenced are only displayed once, so you're safe from
infinite recursion. 

There are several optional parameters, described in the following sections.

=head2 maxhash

The C<maxhash> option allows you to indicate the maximum number of hash elements to display.  
If a hash has more then C<maxhash> elements then none of them are displayed or recursed through,
and instead an indicator of how many elements there are is output.  So, for example, the following
command only displays the hash values if there are 10 or fewer elements in the hash:

   showref $myob, maxhash=>10;
   

If C<maxhash> is not sent then there is no maximum.

=head2 maxarr

The C<maxarr> option allows you to indicate the maximum number of array elements to display.  If
an array has more then C<maxarr> elements then none of them are displayed or recursed through, and
instead an indicator of how many elements there are is output.  If C<maxarr> is not sent then
there is no maximum.


=head2 depth

The C<depth> option allows you to indicate a maximum depth to display in the tree.
If C<depth> is not sent then there is no maximum depth.


=cut

sub showref {
	my ($ref, %opts) = @_;
	my ($indentnum, $indent, $type, $tab, %skip, $finalfh);
	my $fh = $opts{'fh'} || getfh(wantarray);
	
	# hash of keys to skip
	if (defined $opts{'skip'}) {
		$skip{$_} = 1 for asarr($opts{'skip'});
		delete $opts{'skip'};
	}
	
	# set some variables
	$indentnum = $opts{'indent'};
	$indentnum ||= 0;
	$tab = '   ';
	$indent = $tab x $indentnum;
	$opts{'done'} ||= {};	
	
	$type = "$ref";
	$type =~ s|^[^\=]*\=||;
	$type =~ s|\(.*||;

	if (inweb())
		{print $fh "<PRE>\n"}
	
	if (! $indent)
		{print $fh "/----------------------------------------------------------------------------\\\n"}
	
	if ($type eq 'HASH') {
		# if we've recursed to the maximum level
		if (
			$opts{'indent'} && 
			($opts{'indent'}>1) && 
			$opts{'maxhash'} && (keys(%{$ref}) > $opts{'maxhash'}) ) {
			my $count = keys %{$ref};
			
			print $fh
				$indent, '[', $count, ' hash element',
				($count>1 ? 's' : ''), "]\n";
		}

		# else we haven't recursed to the maximum level
		else {
			if ($opts{'labelself'}) {
				print $fh $indent, "HASH\n";
				$indentnum++;
				$indent .= $tab;
			}
			
			ELLOOP:
			while ( my($n, $v) = each(%{$ref}) ) {
				$skip{$n} and next ELLOOP;
				
				print $fh $indent, $n, ' = ';
				
				if (ref $v) {
					if ( $opts{'depth'} ? ($opts{'depth'} >= $indentnum) : 1 ) {
						if ($opts{'done'}->{$v})
							{print $fh "[redundant]\n"}
						else {
							$opts{'done'}->{$v} = 1;
							print $fh "\n";
							showref($v, %opts, done=>$opts{'done'}, indent=>$indentnum+1, fh=>$fh)
						}
					}
					else 
						{print $fh $v}
				}
				elsif (defined $v)
					{print $fh $v, "\n"}
				else
					{print $fh "[undef]\n"}
			}
		}
	}
	
	elsif ($type eq 'ARRAY') {
		print $fh $indent, "ARRAY\n";
		
		if ($opts{'maxarr'} && (@{$ref}) > $opts{'maxarr'} ) {
			print
				$indent, $tab, '[', scalar(@{$ref}), ' element',
				(@{$ref}>1 ? 's' : ''), "]\n";
		}
		
		else {
			my ($firstdone);
			
			foreach my $v ( @{$ref} ) {
				if (ref $v) {
					if ( $opts{'depth'} ? ($opts{'depth'} >= $indentnum) : 1 ) {
						if ($opts{'done'}->{$v})
							{print $fh $indent, $tab, '[redundant]'}
						else {
							$opts{'done'}->{$v} = 1;

							if ($firstdone)
								{print $fh "\n"}
							else
								{$firstdone = 1}
							
							showref($v, %opts, done=>$opts{'done'}, indent=>$indentnum+1, labelself=>1, fh=>$fh)
						}
					}
					else 
						{print $fh $indent, $tab, $v}
				}
				
				elsif (defined $v)
					{print $fh $indent, $tab, $v, "\n"}
				else
					{print $fh $indent, $tab, "[undef]\n"}
			}
		}
	}

	if (! $indent)
		{print $fh "\\----------------------------------------------------------------------------/\n\n"}
	
	if (inweb())
		{print $fh "</PRE>\n"}
	
	ref($fh) and return $fh->mem();
}
# 
# showref
#===================================================================================================


#===================================================================================================
# getfh
# 
# Private sub.  Returns a file handle that is either STDOUT or STDERR (depending 
# on the value of the global variable $Debug::ShowStuff::out), or a MemHandle
# object that will be used to return a string to the caller of the function
# that called getfh.
# 
sub getfh {
	my ($wa) = @_;
	my ($fh);
	
	# if called in void context, outputs to STDOUT,
	# otherwise returns string
	if (defined $wa) {
		require MemHandle;
	    $fh = MemHandle->new;
	}
	else
		{$fh = $out}
	
	return $fh;
}
# 
# getfh
#===================================================================================================


#===================================================================================================
# asarr
# 
# Private function.  Allows an optional argument to be passed as
# either an array reference or as a single item.  Always returns
# an array reference in scalar context and an array in array context.
# 
sub asarr {
	my $arg = shift;
	my @rv;
	
	if (ref $arg)
		{@rv = @$arg}
	else
		{@rv = $arg}
	
	wantarray and return @rv;
	return \@rv;
}
# 
# asarr
#===================================================================================================


#===================================================================================================
# println
# 

=head1 println

In general, works just like C<print>, but adds a newline to the output.

If C<println> is called with no arguments, it simply outputs a newline.
If C<println> is called with exactly one argument, and that argument
is the undefined value, then C<println> outputs "[undef]".  If it is 
called with multiple arguments, and one or more of them is undefined,
then, in normal Perl manner, those undefined's become empty strings
and a warning it output (because, of course, you DO have warnings
turned on, right?).

When C<println> is called in web mode, all arguments are HTML escaped.  
Furthermore, the entire output is enclosed in a C<E<lt>PE<gt>> element 
so that the output is in a paragraph by itself.  The C<E<lt>PE<gt>> element
is given a CSS style so that regardless of the background color and 
font color of the web page, the values sent to C<println> are
displayed with a white background and black text.

=cut

sub println {
	my (@rv, $str);
	my $fh = getfh(wantarray);
	my $i=0;

	# special case: no arguments: just output an eol and return
	if (! @_) {
		print "\n";
		return;
	}
	
	while ($i<=$#_)
		{push @rv, $_[$i++]}
	
	if ( (@rv <= 1) && (! defined $rv[0]) )
		{@rv = '[undef]'}
	
	$str = join('', @rv);
	
	if (inweb())
		{print $fh '<P STYLE="background-color:white;color:black">', htmlesc($str), "</P>\n"}
	else
		{print $fh $str, "\n"}
}
# 
# println
#===================================================================================================


#===================================================================================================
# dieln
# 

=head1 dieln

Works just like the C<die> command, except it always adds an end-of-line to the input
array so you never get those "at line blah-blah-blah" additions.

=cut

sub dieln {
	die @_, "\n";
}
# 
# dieln
#===================================================================================================


#===================================================================================================
# pressenter
# 

=head1 pressenter

For use at the command line.  Outputs a prompt to "press enter to continue", then waits
for you to do exactly that.

=cut

sub pressenter {
	print 'press enter to continue';
	<STDIN>;
}
# 
# pressenter
#===================================================================================================


#===================================================================================================
# httpheader
# 

=head1 httpheader

Outputs an HTTP header.

=cut

sub httpheader {
	my (%opts) = @_;
	
	if (wantarray)
		{return "Content-type:text/html\n\n"}
	
	my $fh = $opts{'fh'} || getfh(wantarray);
	print $fh "Content-type:text/html\n\n";
}

sub httpheaders{return httpheader(@_)}
# 
# header
#===================================================================================================



#===================================================================================================
# showstderr
# 

=head1 showstderr

This function allows you to see, in the web page produced by a CGI, everything
the CGI output to STDERR. 

To use C<showstderr>, assign the return value of the function to a variable that is scoped
to the entire CGI script:

  my $stderr = showstderr();

You need not do anything more with that variable.  The object reference by your variable holds
on to everything output to both STDOUT and STDERR.  When the variable goes out of scope, the 
object outputs the STDOUT content with the STDERR content at the top of the web page.

=cut

sub showstderr {
	return Debug::ShowStuff::ShowStdErr->new(@_);
}
# 
# showstderr
#===================================================================================================



#===================================================================================================
# inweb
# 
=head1 inweb

Returns a guess on if we're in a web environment.  The guess is pretty simple:
if the environment variable C<REQUEST_URI> is true (in the Perlish sense)
then this function returns true.

If the global C<$Debug::ShowStuff::forceplain> is true, this function always
returns false.

=cut

sub inweb {
	$forceplain and return 0;
	return $ENV{'REQUEST_URI'};
}
# 
# inweb
#===================================================================================================



#===================================================================================================
# setoutput
# 

=head1 setoutput

Sets the default output handle.  By default, routines in C<Debug::ShowStuff> output
to STDOUT.  With this command you can set the default output to STDERR, or back
to STDOUT.  The following command sets default output to STDERR:

   setoutput 'stderr';

This command sets output back to STDOUT:

   setoutput 'stdout';

When default output is set to STDERR then the global 
C<$Debug::ShowStuff::forceplain> is set to true, which means that 
functions in this module always output in text mode, not web 
mode.

=cut

sub setoutput {
	my ($outname) = @_;
	
	# STDOUT
	if (lc($outname) eq 'stdout') {
		$out = *STDOUT;
		undef $forceplain;
	}
	
	# STDERR
	elsif (lc($outname) eq 'stderr') {
		$out = *STDERR;
		$forceplain = 1;
	}
	
	# else don't know
	else
		{croak "do not know this type of output: $outname"}
}
# 
# setoutput
#===================================================================================================



#===================================================================================================
# nullfix
# 

=head1 nullfix

Takes a single argument.  If that argument is undefined, returns an
empty string.  Otherwise returns the argument exactly as it is.

=cut

sub nullfix {
	defined($_[0]) or return '';
	return $_[0];
}
# 
# nullfix
#===================================================================================================


######################################################################################################
package Debug::ShowStuff::ShowStdErr;
require 5.005;
use strict;

#---------------------------------------------------------------------------
# new
# 
sub new {
	my ($class, %opts) = @_;
	my $self = bless({}, $class);
	
	# default to HTML environment if environment appears to indicate so
	if ( (! defined $opts{'html'}) && $ENV{'REQUEST_URI'})
		{$opts{'html'} = 1}
	
	# default certain properties based on html
	if ($opts{'html'}) {
		defined($opts{'flushtostderr'}) or $opts{'flushtostderr'} = 1;
		defined($opts{'stderrfirst'})    or $opts{'stderrfirst'} = 1;
	}
	
	# other properties
	$self->{'html'} = $opts{'html'};
	$self->{'flushtostderr'} = $opts{'flushtostderr'};
	$self->{'stderrfirst'} = $opts{'stderrfirst'};
	
	# capture STDERR
	$self->{'stderrdata'} = {'str' => []};
	open(SAVEERR, ">&STDERR") or warn "Cannot save STDERR: $!\n";
	print SAVEERR '';
	$self->{'saveerr'} = *SAVEERR;
	$self->{'caperr'} = tie(*STDERR, $class . '::HandleOb', $self->{'stderrdata'}, %opts);
	
	# capture STDOUT
	if ($opts{'stderrfirst'}) {
		$self->{'stdoutdata'} = {'str' => []};
		
		open(SAVESTD, ">&STDOUT") or warn "Cannot save STDOUT: $!\n";
		print SAVESTD '';
		$self->{'savestd'} = *SAVESTD;
		$self->{'capstd'} = tie(*STDOUT, $class . '::HandleOb', $self->{'stdoutdata'}, %opts);
	}
	
	# warn() doesn't seem to print to STDERR through Perl.  
	# Catch that manually.
	$self->{'oldwarn'} = $SIG{__WARN__};
	$SIG{__WARN__}= sub {print STDERR "@_"};
	
	return $self;
}
# 
# new
#---------------------------------------------------------------------------


#---------------------------------------------------------------------------
# displaystderr
# 
sub displaystderr {
	my ($self) = @_;
	
	# early exit: if there isn't anything in STDERR, do nothing
	unless (@{$self->{'stderrdata'}->{'str'}})
		{return}
	
	# output to the real STDERR if necessary
	if ($self->{'flushtostderr'})
		{print STDERR join("\n",@{$self->{'stderrdata'}->{'str'}})}
	
	# output as HTML if set to do so
	if ($self->{'html'}) {
		print 
			'<DIV STYLE="border-style:solid;border-width:1;padding:5;background-color:CCCCCC;color:black;">',
			"<H2 STYLE=\"margin-top:0px;\">STDERR</H2>\n<PRE>\n";
		
		foreach my $line (@{$self->{'stderrdata'}->{'str'}}) {
			# escape the HTML
			$line =~ s|&|&#38;|g;
			$line =~ s|"|&#34;|g;
			$line =~ s|'|&#39;|g;
			$line =~ s|<|&#60;|g;
			$line =~ s|>|&#62;|g;
			
			# output the line
			print $line;
		}
		
		print "</PRE>\n</DIV>\n\n";
	}
	
	# else output as text
	else {
		print 
			"========================================================================\n",
			"STDERR\n\n", 
			@{$self->{'stderrdata'}->{'str'}}, "\n",
			"========================================================================\n";
	}

}
# 
# displaystderr
#---------------------------------------------------------------------------


#---------------------------------------------------------------------------
# DESTROY
# 
DESTROY {
	my ($self) = @_;
	
	#------------------------------------------------
	# release handles
	#
	$SIG{__WARN__} = $self->{'oldwarn'};
	
	undef $self->{'caperr'}; # as documented in "perltie"
	untie(*STDERR)  or warn("Cannot untie STDERR: $!\n");
	
	# open(STDERR, ">&SAVEERR") or warn("Cannot restore STDERR: $!\n");
	*SAVEERR = $self->{'saveerr'};
	open(STDERR, ">&SAVEERR") or warn("Cannot restore STDERR: $!\n");
	
	if ($@)
		{die "$@"}
	
	# if also capturing stdout
	if ($self->{'stdoutdata'}) {
		undef $self->{'capstd'}; # as documented in "perltie"
		untie(*STDOUT) or warn("Cannot untie STDOUT: $!\n");
		
		*SAVESTD = $self->{'savestd'};
		open(STDOUT, ">&SAVESTD") or warn("Cannot restore STDOUT: $!\n");
		
		if ($@)
			{die "$@"}
	}
	#
	# release handles
	#------------------------------------------------
	
	
	#------------------------------------------------
	# display data
	# 
	if ($self->{'stderrfirst'}) {
		# put STDOUT into string
		my $stdout = join('', @{$self->{'stdoutdata'}->{'str'}});
		
		# if HTML
		if ($self->{'html'}) {
			my ($headers);
			
			# pull out headers
			# this part is a little kludgy
			# I couldn't get the split on the following line
			# to work quite right
			# ($headers, $stdout) = split(m/(\r\n\r\n)/s, $stdout, 2);
			$headers = $stdout;
			$headers =~ s/((\r\n\r\n)|(\n\n)|(\r\r)).*//s;
			$stdout = substr($stdout, length($headers) + length($2));
			
			# output headers
			print $headers, "\n\n";
		}
		
		# output stderr
		$self->displaystderr;
		
		# if stdout has any content, and it doesn't end in
		# a newline, add a newline
		if (  length($stdout) && ($stdout !~ m|[\r\n]$|)  )
			{$stdout .= "\n"}
		
		# output stdout
		print $stdout;
	}

	# else just output STDERR
	else {
		$self->displaystderr;
	}
	#
	# display data
	#------------------------------------------------


}
# 
# DESTROY
#---------------------------------------------------------------------------


######################################################################################################
package Debug::ShowStuff::ShowStdErr::HandleOb;
use strict;
use Carp;


sub TIEHANDLE {
	my($class, $data, %opts) = @_;
	my $self= bless( {} , $class);
	
	$self->{'croakonerr'} = $opts{'croakonerr'};
	$self->{'data'} = $data;
	
	return($self);
}

sub WRITE {
	my($self, $buf, $len, $offset) = @_;
	push @{$self->{'data'}->{'str'}}, $buf;
	return 1;
}

sub PRINT {
	my $self = shift;
	
	# croak if necessary
	if ($self->{'croakonerr'})
		{croak @_}

	push @{$self->{'data'}->{'str'}}, @_;

	return 1;
}

sub PRINTF {
	my $self = shift;
	my $fmt = shift;
	
	# $self->{'data'}->{'str'} .= sprintf($fmt, @_);
	push @{$self->{'data'}->{'str'}}, sprintf($fmt, @_);

	
	return 1;
}

sub AUTOLOAD {
}

sub readwarning {
	carp "Cannot read from specified filehandle.";
}


=head1 TERMS AND CONDITIONS

Copyright (c) 2001-2003 by Miko O'Sullivan.  All rights reserved.  This program is 
free software; you can redistribute it and/or modify it under the same terms 
as Perl itself. This software comes with B<NO WARRANTY> of any kind.

=head1 AUTHORS

Miko O'Sullivan
F<miko@idocs.com>

=head1 VERSION

=over

=item Version 1.00    May 29, 2003

Initial public release

=back




# return true
1;

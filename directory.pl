#!/usr/bin/perl
use strict;
use warnings;

my ($path,$regexExp) = @ARGV;
 
if (not defined $path) {
  die "file path not correctly specified !!,Please try again \n";
} 
my $total=print `find '$path' -name '$regexExp' -printf " %kKB %p\n" > temp.txt`;

`cat << __EOF| gnuplot
set terminal png  size 1920,1080 enhanced font 'Westminster,9'
set output 'overview.png'
set boxwidth 1000
set offsets 0.6, 0.6, 0,0
set xtics border in scale 0,0 nomirror rotate by -80  autojustify
set ylabel "File Size in KB"
set style fill solid
set title "File Sizes"
plot "temp.txt" using 1:xtic(2) with impulses
__EOF`;

open (my $HTML, '>', 'overview.html') or die $!;

print $HTML <<'_END_HEADER_';
<html>
<head><title></title></head>
<body>
_END_HEADER_
my $HTML_path =`pwd`;
print $HTML "<div>$HTML_path $path</div>";

open my $IN, '<', 'temp.txt' or die $!;
while (my $line = <$IN>) {
my $Uid = (stat($path))[4];
my $UserName = ( getpwuid( $Uid ))[0];
my ($var1,$var2,$var3)= split /\s+/,$line;
print $HTML "<div>
<tr><th>$var1  </th></tr>
<tr><th>$var2  </tr></th>
<tr><th> <a href='$var3'>$var3 </a></th></tr>
<tr><th>$UserName </th></tr>
</div>"; 
}

print $HTML "<img src='./overview.png' alt='image not found'/>";
print $HTML '</body></html>';
close $HTML or die $!;

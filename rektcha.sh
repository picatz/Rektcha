#!/bin/bash
# Kent 'picat' Gruber
# Cant'cha?
# A captcha solver using . 

# Captcha Matrix Solver
# +-+-+-+-+-+-+
# |1|2|3|4|5|6|
# +-+-+-+-+-+-+
# |-> 1. 0-9 \____________________
# |-> 2. 0-9 /					  \
# |-> 3. "+" \_ Always addition.   \_ Sum of these two numbers = answer. 
# |-> 4. "+" /					   /
# |-> 5. 0-9 \____________________/					  
# |-> 6. 0-9 /

# Set Defaults
# To view captcha visually in the termianl
catpix_support="off"
# To view captcha visually with ascii 
matrix_support="off"
# To just output result of captcha
number_support="off"
# To output result to file
output_support="off"
output_file="none"
# To output nothing.
silent_support="off"

help_menu() {
	echo -e "rektcha - A captcha solver for a captcha I found. 

EX: ./rektcha.sh -f captcha.png

-f <FILE>\tSolve a given captcha (.png) file.
-o <FILE>\tOutput result of solved captcha to a file.
-r\t\tDisplay just the result of the captcha. 
-c\t\tDisplay captcha with catpix. 
-v\t\tDisplay version.
-s\t\tSilent mode.
-h\t\tDisplay this menu. 
"
}

if [ $# -eq 0 ]; then
    echo "No arguments supplied!"
    help_menu
    exit 1
fi

function version_check {
	echo "Version 1.0"
}

function parseOpts() {
	while getopts :hHrRcCvV:f:F: opt; do
		case $opt in
			h|H) # Help
				help_menu
				exit 0
				;;
			v|V) # Version check 
				version_check
				exit 0
				;;
			c|C) # Catpix support
				catpix_support="on"
				;;
			r|R) # Set file of the captcha to solve
				number_support="on"
				;;
			o|O) # Set file to output the captcha result to.
				output_support="on"
				output_file="$OPTARG"
				;;
			s|S) # Set file to output the captcha result to.
				silent_support="on"
				;;
			f|F) # Set file of the captcha to solve
				captcha_file="$OPTARG"
				;;
			\?) # Invalid arg
				echo "Invalid option: -$OPTARG"
				help_menu
				exit 1
				;;
			:) # Missing arg
				echo "An argument must be specified for -$OPTARG"
				help_menu
				exit 1
				;;
		esac
	done
}

# Parse Arguments
parseOpts "$@"

# So we can easily work without having to worry about messing up the image
cp $captcha_file solving.png

for int in `seq 0 9`;
do
	# Check box 1.
	compare $captcha_file box_1/box1-$int.png result.png
	convert -fuzz 30000  result.png -fill white -opaque red result.png
	convert result.png -auto-level result.png
	check=$(convert result.png box_1/box1-$int.png -compose Difference -composite -colorspace gray -format '%[fx:mean*100]' info:)
	if [ "$check" == "0" ]; then
		box1=$int
	fi
	rm $captcha_file
	cp solving.png $captcha_file

	# Check box 2.
	compare $captcha_file box_2/box2-$int.png result.png
	convert -fuzz 30000  result.png -fill white -opaque red result.png
	convert result.png -auto-level result.png
	check=$(convert result.png box_2/box2-$int.png -compose Difference -composite -colorspace gray -format '%[fx:mean*100]' info:)
	if [ "$check" == "0" ]; then
		box2=$int
	fi
	rm $captcha_file
	cp solving.png $captcha_file

	# Check box 5.
	compare $captcha_file box_5/box5-$int.png result.png
	convert -fuzz 30000  result.png -fill white -opaque red result.png
	convert result.png -auto-level result.png
	check=$(convert result.png box_5/box5-$int.png -compose Difference -composite -colorspace gray -format '%[fx:mean*100]' info:)
	if [ "$check" == "0" ]; then
		box5=$int
	fi
	rm $captcha_file
	cp solving.png $captcha_file

	# Check box 6.
	compare $captcha_file box_6/box6-$int.png result.png
	convert -fuzz 30000  result.png -fill white -opaque red result.png
	convert result.png -auto-level result.png
	check=$(convert result.png box_6/box6-$int.png -compose Difference -composite -colorspace gray -format '%[fx:mean*100]' info:)
	if [ "$check" == "0" ]; then
		box6=$int
	fi
	rm $captcha_file
	cp solving.png $captcha_file
done

# Restore original captcha file.
cp solving.png $captcha_file
# Remove temporary solving files. 
rm solving.png
rm result.png

# He did the math
var1=$box1$box2
var2=$box5$box6
let var1
let var2
result=$(($var1 + $var2))
# He did the monster math

# Handle user options.
if [ $output_support == "on" ]; then
	echo "$result" > $output_file
fi

if [ $number_support == "on" ]; then
	echo "$result"
	exit
fi

if [ $catpix_support == "on" ]; then
	catpix $captcha_file
fi

if [ $silent_support == "off" ]; then
	echo "$var1 + $var2 = $result"
fi

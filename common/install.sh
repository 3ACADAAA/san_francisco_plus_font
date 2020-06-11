ORIGDIR=/sbin/.magisk/mirror
FONTDIR=$MODPATH/custom
SYSFONT=$MODPATH/system/fonts
PRDFONT=$MODPATH/system/product/fonts
SYSETC=$MODPATH/system/etc
SYSXML=$SYSETC/fonts.xml
MODPROP=$MODPATH/module.prop

patch() {
	if i=$(grep 'family >' /system/etc/fonts.xml); then
		cp $ORIGDIR/system/etc/fonts.xml $SYSXML
	else
		find /data/adb/modules* -type f -name fonts.xml -exec rm {} \;
		cp /system/etc/fonts.xml $SYSXML
		sed -ie 3's/$/-!&/' $MODPROP
	fi
	sed -i '/\"sans-serif\">/,/family>/H;1,/family>/{/family>/G}' $SYSXML
	sed -i ':a;N;$!ba;s/name=\"sans-serif\"//2' $SYSXML
}

headline() {
	cp $FONTDIR/hf/*ttf $SYSFONT
	sed -i '/\"sans-serif\">/,/family>/{s/Roboto-M/M/;s/Roboto-B/B/}' $SYSXML
}

body() {
	cp $FONTDIR/bf/*ttf $SYSFONT 
	sed -i '/\"sans-serif\">/,/family>/{s/Roboto-T/T/;s/Roboto-L/L/;s/Roboto-R/R/;s/Roboto-I/I/}' $SYSXML
	nsss
}

condensed() {
	cp $FONTDIR/cf/*ttf $SYSFONT
	sed -i 's/RobotoC/C/' $SYSXML
}

mono() {
	cp $FONTDIR/mo/*ttf $SYSFONT
	sed -i 's/DroidSans//' $SYSXML
}

full() { headline; body; condensed; mono; }

rounded() {
	if [ $HF -eq 2 ]; then cp $FONTDIR/rd/hf/*ttf $SYSFONT; fi
	if [ $BF -eq 2 ]; then cp $FONTDIR/rd/bf/*ttf $SYSFONT; fi
}

text() { cp $FONTDIR/tx/*ttf $SYSFONT; }

bold() {
	SRC=$FONTDIR/bf/bd
	if [ $BF -eq 2 ]; then SRC=$FONTDIR/rd/bf/bd
	elif [ $BF -eq 3 ]; then SRC=$FONTDIR/tx/bd; fi
	if [ $BOLD -eq 1 ]; then cp $SRC/25/*ttf $SYSFONT
	elif [ $BOLD -eq 2 ]; then cp $SRC/50/*ttf $SYSFONT
	else
		sed -i '/\"sans-serif\">/,/family>/{/400/d;/>Light\./{N;h;d};/MediumItalic/G;/>Black\./{N;h;d};/BoldItalic/G}' $SYSXML
		sed -i '/\"sans-serif-condensed\">/,/family>/{/400/d;/-Light\./{N;h;d};/MediumItalic/G}' $SYSXML
	fi
}

legible() {
	SRC=$FONTDIR/bf/hl
	if [ $BF -eq 2 ]; then SRC=$FONTDIR/rd/bf/hl
	elif [ $BF -eq 3 ]; then SRC=$FONTDIR/tx/hl; fi
	cp $SRC/*ttf $SYSFONT
}

clean_up() {
	rm -rf $FONTDIR
	rmdir -p $SYSETC $PRDFONT
}

pixel() {
	if [ -f $ORIGDIR/product/fonts/GoogleSans-Regular.ttf ]; then
		DST=$PRDFONT
	elif [ -f $ORIGDIR/system/fonts/GoogleSans-Regular.ttf ]; then
		DST=$SYSFONT
	fi
	if [ ! -z $DST ]; then
		if [ $PART -eq 1 ]; then
			SRC=$FONTDIR/bf
			if [ $HF -eq 2 ]; then SRC=$FONTDIR/rd/bf; fi
			cp $SRC/Regular.ttf $DST/GoogleSans-Regular.ttf
			cp $FONTDIR/bf/Italic.ttf $DST/GoogleSans-Italic.ttf
			cp $SYSFONT/Medium.ttf $DST/GoogleSans-Medium.ttf
			cp $SYSFONT/MediumItalic.ttf $DST/GoogleSans-MediumItalic.ttf
			cp $SYSFONT/Bold.ttf $DST/GoogleSans-Bold.ttf
			cp $SYSFONT/BoldItalic.ttf $DST/GoogleSans-BoldItalic.ttf
			if [ $BOLD -eq 3 ]; then
				cp $DST/GoogleSans-Medium.ttf $DST/GoogleSans-Regular.ttf
				cp $DST/GoogleSans-MediumItalic.ttf $DST/GoogleSans-Italic.ttf
			fi
		fi
		sed -ie 3's/$/-pxl&/' $MODPROP
		PXL=true
	fi
}

oxygen() {
	if [ -f $ORIGDIR/system/fonts/SlateForOnePlus-Regular.ttf ]; then
		cp $SYSFONT/Black.ttf $SYSFONT/SlateForOnePlus-Black.ttf
		cp $SYSFONT/Bold.ttf $SYSFONT/SlateForOnePlus-Bold.ttf
		cp $SYSFONT/Medium.ttf $SYSFONT/SlateForOnePlus-Medium.ttf
		cp $SYSFONT/Regular.ttf $SYSFONT/SlateForOnePlus-Regular.ttf
		cp $SYSFONT/Regular.ttf $SYSFONT/SlateForOnePlus-Book.ttf
		cp $SYSFONT/Light.ttf $SYSFONT/SlateForOnePlus-Light.ttf
		cp $SYSFONT/Thin.ttf $SYSFONT/SlateForOnePlus-Thin.ttf
		sed -ie 3's/$/-oos&/' $MODPROP
		OOS=true
	fi
}

miui() {
	if i=$(grep miui $SYSXML); then
		if [ $PART -eq 1 ]; then
			sed -i '/\"mipro\"/,/family>/{/700/,/>/s/MiLanProVF/Bold/;/stylevalue=\"400\"/d}' $SYSXML
			sed -i '/\"mipro-regular\"/,/family>/{/700/,/>/s/MiLanProVF/Medium/;/stylevalue=\"400\"/d}' $SYSXML
			sed -i '/\"mipro-medium\"/,/family>/{/400/,/>/s/MiLanProVF/Medium/;/700/,/>/s/MiLanProVF/Bold/;/stylevalue/d}' $SYSXML
			sed -i '/\"mipro-demibold\"/,/family>/{/400/,/>/s/MiLanProVF/Medium/;/700/,/>/s/MiLanProVF/Bold/;/stylevalue/d}' $SYSXML
			sed -i '/\"mipro-semibold\"/,/family>/{/400/,/>/s/MiLanProVF/Medium/;/700/,/>/s/MiLanProVF/Bold/;/stylevalue/d}' $SYSXML
			sed -i '/\"mipro-bold\"/,/family>/{/400/,/>/s/MiLanProVF/Bold/;/700/,/>/s/MiLanProVF/Black/;/stylevalue/d}' $SYSXML
			sed -i '/\"mipro-heavy\"/,/family>/{/400/,/>/s/MiLanProVF/Black/;/stylevalue/d}' $SYSXML
		fi	
		sed -i '/\"mipro\"/,/family>/{/400/,/>/s/MiLanProVF/Regular/;/stylevalue=\"340\"/d}' $SYSXML
		sed -i '/\"mipro-thin\"/,/family>/{/400/,/>/s/MiLanProVF/Thin/;/700/,/>/s/MiLanProVF/Light/;/stylevalue/d}' $SYSXML
		sed -i '/\"mipro-extralight\"/,/family>/{/400/,/>/s/MiLanProVF/Thin/;/700/,/>/s/MiLanProVF/Light/;/stylevalue/d}' $SYSXML
		sed -i '/\"mipro-light\"/,/family>/{/400/,/>/s/MiLanProVF/Light/;/700/,/>/s/MiLanProVF/Regular/;/stylevalue/d}' $SYSXML
		sed -i '/\"mipro-normal\"/,/family>/{/400/,/>/s/MiLanProVF/Light/;/700/,/>/s/MiLanProVF/Regular/;/stylevalue/d}' $SYSXML
		sed -i '/\"mipro-regular\"/,/family>/{/400/,/>/s/MiLanProVF/Regular/;/stylevalue=\"340\"/d}' $SYSXML
		sed -ie 3's/$/-miui&/' $MODPROP
		MIUI=true
	fi
}

lg() {
	if i=$(grep lg-sans-serif $SYSXML); then
		sed -i '/\"lg-sans-serif\">/,/family>/{/\"lg-sans-serif\">/!d};/\"sans-serif\">/,/family>/{/\"sans-serif\">/!H};/\"lg-sans-serif\">/G' $SYSXML
		LG=true
	fi
	if [ -f $ORIGDIR/system/etc/fonts_lge.xml ]; then
		cp $ORIGDIR/system/etc/fonts_lge.xml $SYSETC
		LGXML=$SYSETC/fonts_lge.xml
		sed -i '/\"default_roboto\">/,/family>/{s/Roboto-T/T/;s/Roboto-L/L/;s/Roboto-R/R/;s/Roboto-I/I/}' $LGXML
		if [ $PART -eq 1 ]; then
			sed -i '/\"default_roboto\">/,/family>/{s/Roboto-M/M/;s/Roboto-B/B/}' $LGXML
			if [ $BOLD -eq 3 ]; then
				sed -i '/\"default_roboto\">/,/family>/{/400/d;/>Light\./{N;h;d};/MediumItalic/G}' $LGXML
			fi
		fi
		LG=true
	fi
	if $LG; then sed -ie 3's/$/-lg&/' $MODPROP; fi
}

rom() {
	pixel
	if ! $PXL; then oxygen
		if ! $OOS; then miui
			if ! $MIUI; then lg
			fi
		fi
	fi
}

googlesans() {
	if i=$(grep -e 'hf-' -e 'hf$' $MODULEROOT/googlesansplus/module.prop); then
		SYSXML=$MODULEROOT/googlesansplus/system/etc/fonts.xml
		GS=true
	elif i=$(grep -e 'hf-' -e 'hf$' $NVBASE/modules/googlesansplus/module.prop); then
		SYSXML=$NVBASE/modules/googlesansplus/system/etc/fonts.xml
		GS=true
	fi
	if $GS; then sed -ie 3's/$/-GS&/' $MODPROP; fi
}

### SELECTIONS ###

OPTION=false
PART=1
HF=1
BF=1
BOLD=0
LEGIBLE=false

GS=false
googlesans

ui_print "   "
ui_print "- Enable OPTIONS?"
ui_print "  Vol+ = Yes; Vol- = No"
ui_print "   "
if $VKSEL; then
	OPTION=true	
	ui_print "  Selected: Yes"
else
	ui_print "  Selected: No"	
fi

if $OPTION; then

	if $GS; then
		ui_print "   "
		ui_print "- WHERE to install?"
		ui_print "  Vol+ = Select; Vol- = Ok"
		ui_print "   "
		ui_print "  1. Full"
		ui_print "  2. Body"
		ui_print "   "
		ui_print "  Select:"
		while true; do
			ui_print "  $PART"
			if $VKSEL; then
				PART=$((PART + 1))
			else 
				break
			fi
			if [ $PART -gt 2 ]; then
				PART=1
			fi
		done
		ui_print "   "
		ui_print "  Selected: $PART"
	fi

	if [ $PART -eq 1 ]; then
		ui_print "   "
		ui_print "- Which HEADLINE font style?"
		ui_print "  Vol+ = Select; Vol- = OK"
		ui_print "   "
		ui_print "  1. Default"
		ui_print "  2. Rounded"
		ui_print "   "
		ui_print "  Select:"
		while true; do
			ui_print "  $HF"
			if $VKSEL; then
				HF=$((HF + 1))
			else 
				break
			fi
			if [ $HF -gt 2 ]; then
				HF=1
			fi
		done
		ui_print "   "
		ui_print "  Selected: $HF"
	else
		HF=0
	fi

	ui_print "   "
	ui_print "- Which BODY font style?"
	ui_print "  Vol+ = Select; Vol- = OK"
	ui_print "   "
	ui_print "  1. Default"
	ui_print "  2. Rounded"
	ui_print "  3. Text"
	ui_print "   "
	ui_print "  Select:"
	while true; do
		ui_print "  $BF"
		if $VKSEL; then
			BF=$((BF + 1))
		else 
			break
		fi
		if [ $BF -gt 3 ]; then
			BF=1
		fi
	done
	ui_print "   "
	ui_print "  Selected: $BF"

	ui_print "   "
	ui_print "- Use BOLD font?"
	ui_print "  Vol+ = Yes; Vol- = No"
	ui_print "   "
	if $VKSEL; then
		BOLD=1
		ui_print "  Selected: Yes"
	else
		ui_print "  Selected: No"	
	fi

	if [ $BOLD -eq 1 ]; then
		ui_print "   "
		ui_print "- How much BOLD?"
		ui_print "  Vol+ = Select; Vol- = OK"
		ui_print "   "
		ui_print "  1. Light"
		ui_print "  2. Medium"
		if [ $HF -eq $BF ]; then
			ui_print "  3. Strong"
		fi
		ui_print "   "
		ui_print "  Select:"
		while true; do
			ui_print "  $BOLD"
			if $VKSEL; then
				BOLD=$((BOLD + 1))
			else 
				break
			fi
			if [ $BOLD -gt 2 ] && [ $HF -ne $BF ]; then
				BOLD=1
			elif [ $BOLD -gt 3 ] ; then
				BOLD=1
			fi
		done
		ui_print "   "
		ui_print "  Selected: $BOLD"
	fi

	if [ $BOLD -eq 0 ]; then
		ui_print "   "
		ui_print "- High Legibility?"
		ui_print "  Vol+ = Yes; Vol- = No"
		ui_print "   "
		if $VKSEL; then
			LEGIBLE=true
			ui_print "  Selected: Yes"
		else
			ui_print "  Selected: No"	
		fi
	fi

fi #OPTIONS

### INSTALLATION ###
ui_print "   "
ui_print "- Installing"

mkdir -p $SYSFONT $SYSETC $PRDFONT
if [ $PART -eq 1 ]; then patch; fi

case $PART in
 	1 ) full;;
 	2 ) body; condensed; mono; sed -ie 3's/$/-bf&/' $MODPROP;;
esac

case $HF in
	2 ) rounded; sed -ie 3's/$/-hfrnd&/' $MODPROP;;
esac

case $BF in
	2 ) rounded; sed -ie 3's/$/-bfrnd&/' $MODPROP;;
	3 ) text; sed -ie 3's/$/-bftxt&/' $MODPROP;;
esac

if [ $BOLD -ne 0 ]; then
	bold; sed -ie 3's/$/-bld&/' $MODPROP
fi

if $LEGIBLE; then
	legible; sed -ie 3's/$/-lgbl&/' $MODPROP
fi

PXL=false; OOS=false; MIUI=false; LG=false
rom

### CLEAN UP ###
ui_print "- Cleaning up"
clean_up

ui_print "   "

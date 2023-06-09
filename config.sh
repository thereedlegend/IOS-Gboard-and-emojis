##########################################################################################
#
# Unity Config Script
# by topjohnwu, modified by Zackptg5
#
##########################################################################################

##########################################################################################
# Installation Message - Don't change this
##########################################################################################

print_modname() {
  ui_print " "
  ui_print "    *******************************************"
  ui_print "    *      Gboard IOS Themes and Emoji's      *"
  ui_print "    *******************************************"
  ui_print "    *               v2 (extended)             *"
  ui_print "    *              by Satoru Reed             *"
  ui_print "    *******************************************"
  ui_print " "
}

##########################################################################################
# Defines
##########################################################################################


# Uncomment and change 'MINAPI' and 'MAXAPI' to the minimum and maxium android version for your mod (note that unity's minapi is 17) due to bash)
# Uncomment DYNAMICOREO if you want libs installed to vendor for oreo+ and system for anything older
# Uncomment SYSOVERRIDE if you want the mod to always be installed to system (even on magisk) - note that this can still be set to true by the user by adding 'sysover' to the zipname
# Uncomment DEBUG if you want full debug logs (saved to /sdcard in magisk manager and the zip directory in twrp) - note that this can still be set to true by the user by adding 'debug' to the zipname
#MINAPI=21
#MAXAPI=25
#DYNAMICOREO=true
#SYSOVERRIDE=true
#DEBUG=true

# Things that ONLY run during an upgrade (occurs after unity_custom) - you probably won't need this
# A use for this would be to back up app data before it's wiped if your module includes an app
# NOTE: the normal upgrade process is just an uninstall followed by an install
unity_upgrade() {
  : # Remove this if adding to this function
}

# Custom Variables for Install AND Uninstall - Keep everything within this function - runs before uninstall/install
unity_custom() {
  : # Remove this if adding to this function
}

# Custom Functions for Install AND Uninstall - You can put them here


##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# By default Magisk will merge your files with the original system
# Directories listed here however, will be directly mounted to the correspond directory in the system

# You don't need to remove the example below, these values will be overwritten by your own list
# This is an example
REPLACE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here, it will overwrite the example
# !DO NOT! remove this if you don't need to replace anything, leave it empty as it is now
REPLACE="
"

##########################################################################################
# Custom Permissions
##########################################################################################

set_permissions() {
  : # Remove this if adding to this function

  # Note that all files/folders have the $UNITY prefix - keep this prefix on all of your files/folders
  # Also note the lack of '/' between variables - preceding slashes are already included in the variables
  # Use $VEN for vendor (Do not use /system$VEN, the $VEN is set to proper vendor path already - could be /vendor, /system/vendor, etc.)

  # Some examples:

  # For directories (includes files in them):
  # set_perm_recursive  <dirname>                <owner> <group> <dirpermission> <filepermission> <contexts> (default: u:object_r:system_file:s0)

  # set_perm_recursive $UNITY/system/lib 0 0 0755 0644
  # set_perm_recursive $UNITY$VEN/lib/soundfx 0 0 0755 0644

  # For files (not in directories taken care of above)
  # set_perm  <filename>                         <owner> <group> <permission> <contexts> (default: u:object_r:system_file:s0)

  # set_perm $UNITY/system/lib/libart.so 0 0 0644
}

on_install() {
  #Definitions
  MSG_DIR="/data/data/com.facebook.orca"
  FB_DIR="/data/data/com.facebook.katana"
  EMOJI_DIR="app_ras_blobs"
  FONT_DIR=$MODPATH/system/fonts
  FONT_EMOJI="NotoColorEmoji.ttf"
  ui_print "- Extracting module files"
  ui_print "- Installing Emojis"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2

  #Compatibility with different devices and potential Support for Android 13?
  variants='SamsungColorEmoji.ttf LGNotoColorEmoji.ttf HTC_ColorEmoji.ttf AndroidEmoji-htc.ttf ColorUniEmoji.ttf DcmColorEmoji.ttf CombinedColorEmoji.ttf NotoColorEmojiLegacy.ttf'
  for i in $variants ; do
        if [ -f "/system/fonts/$i" ]; then
            cp $FONT_DIR/$FONT_EMOJI $FONT_DIR/$i && ui_print "- Replacing $i"
        fi
  done
  
  #Facebook Messenger
  if [ -d "$MSG_DIR" ]; then
    ui_print "- Replacing Messenger Emojis"
    cd $MSG_DIR
    rm -rf $EMOJI_DIR
    mkdir $EMOJI_DIR
    cd $EMOJI_DIR
    cp $MODPATH/system/fonts/$FONT_EMOJI ./FacebookEmoji.ttf
  fi
  
  #Facebook App
  if [ -d "$FB_DIR" ]; then
    ui_print "- Replacing Facebook Emojis"
    cd $FB_DIR
    rm -rf $EMOJI_DIR
    mkdir $EMOJI_DIR
    cd $EMOJI_DIR
    cp $MODPATH/system/fonts/$FONT_EMOJI ./FacebookEmoji.ttf
  fi
  
  #Verifying Android version
  android_ver=$(getprop ro.build.version.sdk)
  #if Android 12 detected
  if [ $android_ver -ge 31 ]; then
        DATA_FONT_DIR="/data/fonts/files"
    if [ -d "$DATA_FONT_DIR" ] && [ "$(ls -A $DATA_FONT_DIR)" ]; then
            ui_print "- Android 12 or higher Detected"
            ui_print "- Checking [$DATA_FONT_DIR]"
        for dir in $DATA_FONT_DIR/*/ ; do
                cd $dir
            for file in * ; do
                if [ "$file" == *ttf ] ; then
                    cp $FONT_DIR/$FONT_EMOJI $file 
                fi
                done
        done
    fi
  fi
  
  
  [[ -d /sbin/.core/mirror ]] && MIRRORPATH=/sbin/.core/mirror || unset MIRRORPATH
  FONTS=/system/etc/fonts.xml
  FONTFILES=$(sed -ne '/<family lang="und-Zsye".*>/,/<\/family>/ {s/.*<font weight="400" style="normal">\(.*\)<\/font>.*/\1/p;}' $MIRRORPATH$FONTS)
  for font in $FONTFILES
  do
    ln -s /system/fonts/NotoColorEmoji.ttf $MODPATH/system/fonts/$font
  done
}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm_recursive /data/data/com.facebook.katana/app_ras_blobs/FacebookEmoji.ttf 0 0 0755 700
  set_perm_recursive /data/data/com.facebook.katana/app_ras_blobs 0 0 0755 755
  set_perm_recursive /data/data/com.facebook.orca/app_ras_blobs/FacebookEmoji.ttf 0 0 0755 700
}

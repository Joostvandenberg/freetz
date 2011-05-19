if (isFreetzType 7320 || (isFreetzType 7240 7270 7390 && isFreetzType LABOR_PREVIEW)); then

# Emergency stop switch for execution of debug.cfg
sed -i -r 's#(\. /var/flash/debug\.cfg)#[ "$dbg_off" == "y" ] || \1#g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.tail.sh"

cat << 'EOF' > "${FILESYSTEM_MOD_DIR}/etc/init.d/S80-rcmod"
# Emergency stop switch for execution of Freetz as a whole
[ "$ds_off" == "y" ] || . /etc/init.d/rc.mod 2>&1 | tee /var/log/mod.log

EOF

else

# Emergency stop switch for execution of debug.cfg
sed -i -r 's#(\. /var/flash/debug\.cfg)#[ "$dbg_off" == "y" ] || \1#g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

# Emergency stop switch for execution of Freetz as a whole
echo '[ "$ds_off" == "y" ] || . /etc/init.d/rc.mod 2>&1 | tee /var/log/mod.log' >> "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

fi

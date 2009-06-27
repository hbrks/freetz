--- etc/init.d/rc.net.orig	2008-12-17 22:22:17.000000000 +0100
+++ etc/init.d/rc.net	2008-12-17 22:22:17.000000000 +0100
@@ -57,9 +57,25 @@
    WLAN_TEST=0
 fi
 
+# Do we have a UPnP server (upnpd) or was ist stripped from the firmware?
+_upnpd=$(basename $(which upnpd) 2> /dev/null)
+# Does a multid option to start without UPnP device (-U) exist?
+_multid_upnp=$(/sbin/multid -? 2>&1 | grep upnp)
+# Does a dsld option to start without igd (-g) exist?
+_dsld_upnp=$(/sbin/dsld -? 2>&1 | grep igd)
+# Set multid "no UPnP" option, if
+#   a) it has the parameter at all AND
+#   b) upnpd binary does *not* exist
+[ "$_multid_upnp" ] && [ ! "$_upnpd" ] && MULTIDPARAM="$MULTIDPARAM -U"
+# Set dsld "no igd" option, if
+#   a) it has the parameter at all AND
+#   b) upnpd binary does *not* exist
+[ "$_dsld_upnp" ] && [ ! "$_upnpd" ] && DSLDDPARAM="-g"
+
 
 upnpdstart()
 {
+	 [ "$_upnpd" ] || return;
    if [ "`pidof upnpd`" = "" ] ; then
       upnpd $VERBOSEPARAM
       sleep 1
@@ -285,9 +301,9 @@
    if [ "$CONFIG_DSL" ] ; then
      if [ "`pidof dsld`" = "" ] ; then
        if [ "$CONFIG_RAMSIZE" = 8 ] ; then
-         dsld -i -n $NICEPARAM -r 600 $VERBOSEPARAM
+         dsld -i -n $NICEPARAM -r 600 $VERBOSEPARAM $DSLDDPARAM
        else
-         dsld -i -n $NICEPARAM $VERBOSEPARAM
+         dsld -i -n $NICEPARAM $VERBOSEPARAM $DSLDDPARAM
        fi
      fi
    fi

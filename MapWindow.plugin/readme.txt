MapWindow.plugin, version 2.0.1
By Soludra Ar'thela

+--------------+
| Requirements |
+--------------+

* MUSHclient v4.56 or higher
* GMCP plugin, by Soludra

+--------------+
| Installation |
+--------------+

1. In MUSHclient, File -> Plugins.
2. Click Add.
3. Browse to the same directory as this readme.txt
4. Select 'plugin.xml' and click Open.

If using alongside compass.plugin and gauges.plugin in their original positions:
5. Use the alias "MAP MOVE 0 152". This should position the map just below the
   gauges.
6. Use MAP WIDTH 4 to make the map fit between the edge of the screen and the text.

+-------+
| Usage |
+-------+

This plugin takes the MAP output and creates a floating miniwindow with it. It
automatically updates itself as you move.

Use MAP HELP to view the list of commands that can be used.

+----------------------------+
| Frequently Asked Questions |
+----------------------------+

1. The map doesn't appear/update!
A. The plugin may not be enabled. Go to File -> Plugins and make sure it's
   enabled.
   
   You may also be in an area where there is no map; you should use MAP yourself
   to check.
   
   In some cases - after death, or after passing through unmapped terrain, for
   instance - the map may not update. You should use MAP once or twice manually.
   This is a known issue.
   
   Please also see the Troubleshooting section for the GMCP plugin.

2. Nothing's appearing on the screen, but I see my health falling! (or other
   gagged-output issues)
A. In semi-rare cases, the MapWindow will gag everything in its path. This is a
   known issue. You should use MAP once or twice to kick it back into gear.
   
   In general, if something strange happens regarding the map, using MAP once
   or twice manually should, in most cases, get it working again.

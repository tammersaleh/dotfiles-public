You're a linux expert.  I'm writing a bash script. I have a $file variable that points to a file that may or may not start with a shebang line (a line that starts with the special characters #!).  I want to cat this file, removing the shebang line if it's there.  If it's not there, cat the entire file.

Use gnu sed for this.

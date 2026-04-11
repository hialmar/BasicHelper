#labels
 ' This is an example that calls
 ' an assembler routine from a
 ' BASIC program by name.
 HIMEM#7FFF:CLOAD"" ' Load module
 PRINT "This is some Text displayed in BASIC"
 PRINT "And the italics effect is done by "
 PRINT "calling an ASM routine."
 CALL  32769  ' Italics!

#labels
' Set a few defines that can be useful
#define TextStart #BB80
#define ScreenWidth 40
#define Paper 16
#define Red 1
#define Green 2
 '
 ' This shows how to use
 ' symbolic names instead
 ' of hardcoded values
 '
 ' RED PAPER on top left
 POKE#BB80,16+1
 ' and GREEN PAPER next
 POKE TextStart+1,Paper+Green

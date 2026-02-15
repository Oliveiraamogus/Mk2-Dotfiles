cd .\src\exceptions\
echo package exceptions; >> "%1.java"
echo public class %1 extends RuntimeException{ >> "%1.java"
echo     static final long serialVersionUID = 0L; >> "%1.java"
echo } >> "%1.java"
::echo package exceptions; public class %1 extends RuntimeException{ static final long serialVersionUID = 0L; } >> "%1.java"


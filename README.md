# Setup
Source the setup.sh script from within this repo directory:
( Be aware that running/sourcing setup.sh when fuzzing is running will mess up fuzzing and it will have to be restarted. )
``` sh
source setup.sh
```
You need to build radare2 with AFL++ and copy libr/* and radare2 binary in targets. You can use the copyrel.sh script for copying the files
<TODO: add more instructions>
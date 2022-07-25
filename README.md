# CartesiAutomation

Cartesi Rollups ToolKit is a tool that provides unified and simplified way of executing all of the task related to Cartesi rollups dapp.
The tasks are: creating, building, deploying a dapp and also starting and stoping the rollup in both 'host' and 'prod' mode.
This tool wraps all the required commands and provides easy to remember syntax to call them.
The tool works equally with both custom dapps and Cartesi examples.

## Installing

Make sure that the script has execution permissions:
```shell
chomd +x cartesi_rollups_toolkit.sh
```

Before using the script it must be installed with this command:
```shell
./cartesi_rollups_toolkit.sh install
```
Close the current console window and then reopen it.

*Note: The installation updates __.bashrc__ file so the console window must be reopened for the changes to take effect.*

After installation is complete this script can operate in any directory. It is set as alias and it can be called by typing
```shell
crt
```

## Examples

```shell
crt -v
```
Shows information about the dapp in the current directory.

```shell
crt prod start
```
Starts the rollup in production mode.

```shell
crt host stop
```
Stops the rollup from host mode.

```shell
crt host start --log
```
Starts the rollup in host mode and also writes the output to a log file.

```shell
crt build --hint
```
Only shows the command used to run the build tasks without actually executing it.

## Arguments

**-h, --help**

Shows this help page.

**-v, --version**

Shows version and information about the dapp located in current directory.
Alsow shows the current version of docker and if it meets the minimum requirements.

**install**

Allows this script to operate in any directory. It is set as alias and it can be called by typing 'crt'
Note: Installation will take effect in newly opened shells.

~~**uninstall**~~

*(not yet available) - Remove the alias to this script.*

**-b, build**

Builds the dapp.

**-u, up, start**

Starts the rollup in 'host' or 'prod' mode.
Note: The mode needs to be specified using the -m argument.

**-d, down, stop**

Stops the rollup from 'host' or 'prod' mode.
Note: The mode needs to be specified using the -m argument.

**-r, restart**

Restarts the rollup by stopping and then starting.
Also works if both 'stop' and 'start' arguments are provided.
Note: The mode needs to be specified using the -m argument.

**-m, --mode**

Specifies in what mode the dapp will run. Supported modes are 'host' and 'prod'.

**host**

Same as '-m host'

**prod, production**

Same as '-m prod'

~~**-c, create**~~

*(not yet available) - Creates new dapp at current directory.*

~~**-y, deploy**~~

*(not yet available) - Deploys the dapp.*

**--hint**

Only shows command used to execute specified task without actually executing it.
Works with: build, start, stop, restart, env-init

**-l, --log**

Creates log file with the ouput of the executed task. Log files are located in directory /logs.
Works with: build, start, stop, restart
Note: The executed command is piped to 'tee', so it outputs both on the screen and in a log file.

**--ei, env-init**

Initializes host mode for the dapp by creating virtual environment and installing the required libraries.
Note: Python only.

**--er, env-run**

*(in development, still some issues) - Runs the dapp in virtual environment when the rollup operates in host mode.*

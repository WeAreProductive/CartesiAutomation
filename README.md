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

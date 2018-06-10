# fastly-api-examples
A set of example scripts for using the Fastly API.

## Introduction
These are for demonstrating the various API functions in a very simple reference
way. They are not intended for use directly, but as a way to see how to make
each API call. This can then form the base of building out scripts to interact
with the API.

Most commonly Fastly's API is used with a client tool set such as Chef, Terraform,
Puppet, or one of the many other configuration management systems. In general
these are a better way to interact, but to build them or one's own scripts the
code here can act as a guide.

There are some basic tools in the `utils/` directory. The main template examples
live in the `examples/` directory. Each of the template scripts can be run on a
service and will leave the service in the same state as it was originally albeit
possibly more versions along.

**DO NOT USE THESE ON A LIVE OR PRODUCTION SERVICE.**

## Usage
If this is the first time using these scripts, create a new token and credentials
file by running `generate_api_credentials.sh` from the `utils/` directory. This
will set up a file with all the credentials to run the rest of the scripts.

Once that is in place, find the function you want to look at in the `examples/`
directory and you examine the various commands that are run to create, update,
show and delete the various endpoints the API provides.

Each script file is heavily documented to assist in explaining what each API
call does.

## Contributing
Contributions are very welcome. To contribute more examples or tools, fork the
repository. Make the changes you want to be added. Create a pull request.

1 simple rule. Be nice. If you can't be nice (kind, supportive) then thanks for
considering contributing, but no thanks.

If you find bugs or issues, please enter a bug report with full steps and
details necessary to reproduce.

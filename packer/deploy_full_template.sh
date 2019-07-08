#!/bin/bash

#packer validate -var-file=variables_full.json immutable.json |
packer build -var-file=variables_full.json immutable.json

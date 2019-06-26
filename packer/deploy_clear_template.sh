#!/bin/bash

#packer validate -var-file=variables.json ubuntu16.json |
packer build -var-file=variables.json ubuntu16.json

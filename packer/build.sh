#!/bin/bash

IMAGEVERSION=$1

packer build -var "version=${IMAGEVERSION}" .
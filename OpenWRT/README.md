# OpenWRT Build Configuration for BPI-R4

This folder contains configuration files for building a custom OpenWRT image for the **BPI-R4 router**.

## Contents

- **Packages.txt** - A list of packages included in this OpenWRT build. These are the software packages and utilities that will be pre-installed when flashing the custom image to the router.

## Purpose

The `Packages.txt` file specifies which packages (applications, libraries, network tools, etc.) should be compiled and included in the final OpenWRT firmware for the BPI-R4. This allows you to create a customized build tailored to your specific needs without unnecessary bloat.

## Usage

When building OpenWRT for the BPI-R4, reference the packages listed in `Packages.txt` during the configuration step to ensure they are included in your final image.

Or just use the custom packages option on the OpenWRT firmware selector webpage.
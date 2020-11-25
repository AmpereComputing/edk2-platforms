## @file
#
# Copyright (c) 2020, Ampere Computing LLC. All rights reserved.<BR>
#
# SPDX-License-Identifier: BSD-2-Clause-Patent
#
##

################################################################################
#
# Defines Section - statements that will be processed to create a Makefile.
#
################################################################################
[Defines]
  PLATFORM_NAME                  = Jade
  PLATFORM_GUID                  = 7BDD00C0-68F3-4CC1-8775-F0F00572019F
  PLATFORM_VERSION               = 0.1
  DSC_SPECIFICATION              = 0x0001001B
  OUTPUT_DIRECTORY               = Build/Jade
  SUPPORTED_ARCHITECTURES        = AARCH64
  BUILD_TARGETS                  = DEBUG|RELEASE
  SKUID_IDENTIFIER               = DEFAULT
  FLASH_DEFINITION               = Platform/Ampere/JadePkg/Jade.fdf

  #
  # Defines for default states. These can be changed on the command line.
  # -D FLAG=VALUE
  #
  DEFINE DEBUG_PRINT_ERROR_LEVEL = 0x8000000F
  DEFINE FIRMWARE_VER            = 0.01.001
  DEFINE EDK2_SKIP_PEICORE       = TRUE
  DEFINE SECURE_BOOT_ENABLE      = FALSE
  DEFINE INCLUDE_TFTP_COMMAND    = TRUE
  DEFINE UEFI_UUID               = 21A80447-B2DD-4D8C-BCA2-04305F025EA4

  #
  # Network definition
  #
  DEFINE NETWORK_IP6_ENABLE                  = TRUE
  DEFINE NETWORK_HTTP_BOOT_ENABLE            = TRUE
  DEFINE NETWORK_ALLOW_HTTP_CONNECTIONS      = TRUE
  DEFINE NETWORK_TLS_ENABLE                  = TRUE

# Include default Ampere Platform DSC file
!include Silicon/Ampere/AmpereAltraPkg/Ac01Pkg.dsc.inc

################################################################################
#
# Specific Platform Library
#
################################################################################
[LibraryClasses]

  #
  # RTC Library: Common RTC
  #
  RealTimeClockLib|Platform/Ampere/JadePkg/Library/PCF85063RealTimeClockLib/PCF85063.inf

  #
  # Library for FailSafe support
  #
  FailSafeLib|Platform/Ampere/Library/FailSafeLib/FailSafeLib.inf

  #
  # ACPI Libraries
  #
  AcpiLib|EmbeddedPkg/Library/AcpiLib/AcpiLib.inf
  AcpiHelperLib|Platform/Ampere/Library/AcpiHelperLib/AcpiHelperLib.inf
  AcpiPccLib|Platform/Ampere/Library/AcpiPccLib/AcpiPccLib.inf

  #
  # Pcie Board
  #
  PcieBoardLib|Platform/Ampere/JadePkg/Library/Pcie/BoardPcie.inf

################################################################################
#
# Specific Platform Pcds
#
################################################################################
[PcdsFeatureFlag.common]
  #
  # Activate AcpiSdtProtocol
  #
  gEfiMdeModulePkgTokenSpaceGuid.PcdInstallAcpiSdtProtocol|TRUE

[PcdsFixedAtBuild]
!ifdef $(FIRMWARE_VER)
  gEfiMdeModulePkgTokenSpaceGuid.PcdFirmwareVersionString|L"$(FIRMWARE_VER)"
!endif

[PcdsFixedAtBuild.common]
  gAmpereTokenSpaceGuid.PcdSmbiosTables1MajorVersion|$(MAJOR_VER)
  gAmpereTokenSpaceGuid.PcdSmbiosTables1MinorVersion|$(MINOR_VER)

!if $(SECURE_BOOT_ENABLE) == TRUE
  # Override the default values from SecurityPkg to ensure images
  # from all sources are verified in secure boot
  gEfiSecurityPkgTokenSpaceGuid.PcdOptionRomImageVerificationPolicy|0x04
  gEfiSecurityPkgTokenSpaceGuid.PcdFixedMediaImageVerificationPolicy|0x04
  gEfiSecurityPkgTokenSpaceGuid.PcdRemovableMediaImageVerificationPolicy|0x04
!endif

[PcdsDynamicDefault.common.DEFAULT]
  # SMBIOS Type 0 - BIOS Information
  gAmpereTokenSpaceGuid.PcdSmbiosTables0BiosVendor|"Ampere Computing"
  gAmpereTokenSpaceGuid.PcdSmbiosTables0BiosVersion|"TianoCore EDKII"
  gAmpereTokenSpaceGuid.PcdSmbiosTables0BiosReleaseDate|"MM/DD/YYYY"

  # SMBIOS Type 1 - System Information
  gAmpereTokenSpaceGuid.PcdSmbiosTables1SystemManufacturer|"Ampere Computing"
  gAmpereTokenSpaceGuid.PcdSmbiosTables1SystemProductName|"Mt Jade"
  gAmpereTokenSpaceGuid.PcdSmbiosTables1SystemVersion|"0.3"
  gAmpereTokenSpaceGuid.PcdSmbiosTables1SystemSerialNumber|"0123-4567-89AB-CDEF"
  gAmpereTokenSpaceGuid.PcdSmbiosTables1SystemSkuNumber|"01234567"

[PcdsPatchableInModule]
  #
  # Console Resolution (HD mode)
  #
  gEfiMdeModulePkgTokenSpaceGuid.PcdVideoHorizontalResolution|1024
  gEfiMdeModulePkgTokenSpaceGuid.PcdVideoVerticalResolution|768

################################################################################
#
# Specific Platform Component
#
################################################################################
[Components.common]
  #
  # FailSafe and Watchdog Timer
  #
  Platform/Ampere/Drivers/FailSafeDxe/FailSafeDxe.inf

  #
  # ACPI
  #
  MdeModulePkg/Universal/Acpi/AcpiTableDxe/AcpiTableDxe.inf {
    <PcdsFixedAtBuild>
      gEfiMdePkgTokenSpaceGuid.PcdDebugPropertyMask|0x2B
  }
  Platform/Ampere/JadePkg/Drivers/AcpiPlatformDxe/AcpiPlatformDxe.inf
  Platform/Ampere/JadePkg/AcpiTables/AcpiTables.inf

  #
  # VGA ASpeed
  #
  Drivers/ASpeed/ASpeedGopBinPkg/ASpeedAst2500GopDxe.inf

  # SMBIOS
  #
  MdeModulePkg/Universal/SmbiosDxe/SmbiosDxe.inf
  Platform/Ampere/JadePkg/Drivers/SmbiosPlatformDxe/SmbiosPlatformDxe.inf
  Platform/Ampere/JadePkg/Drivers/SmbiosCpuDxe/SmbiosCpuDxe.inf
  Platform/Ampere/JadePkg/Drivers/SmbiosMemInfoDxe/SmbiosMemInfoDxe.inf

  #
  # HII
  #
  Silicon/Ampere/AmpereAltraPkg/Drivers/PlatformInfoDxe/PlatformInfoDxe.inf
  Silicon/Ampere/AmpereAltraPkg/Drivers/MemInfo/MemInfoDxe.inf
  Silicon/Ampere/AmpereAltraPkg/Drivers/CpuConfigDxe/CpuConfigDxe.inf
  Silicon/Ampere/AmpereAltraPkg/Drivers/AcpiConfigDxe/AcpiConfigDxe.inf

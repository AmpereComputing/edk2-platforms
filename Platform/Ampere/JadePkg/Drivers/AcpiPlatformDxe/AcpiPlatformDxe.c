/** @file

  Copyright (c) 2020, Ampere Computing LLC. All rights reserved.<BR>

  SPDX-License-Identifier: BSD-2-Clause-Patent

**/

#include "AcpiPlatform.h"

STATIC EFI_EVENT mAcpiRegistration = NULL;

/*
 * This GUID must match the FILE_GUID in AcpiTables.inf of each boards
 */
STATIC CONST EFI_GUID mJadeAcpiTableFile = { 0x5addbc13, 0x8634, 0x480c, { 0x9b, 0x94, 0x67, 0x1b, 0x78, 0x55, 0xcd, 0xb8 } };

/**
 * Callback called when ACPI Protocol is installed
 */
STATIC VOID
AcpiNotificationEvent (
  IN  EFI_EVENT                Event,
  IN  VOID                     *Context
  )
{
  EFI_STATUS  Status;
  EFI_ACPI_3_0_ROOT_SYSTEM_DESCRIPTION_POINTER  *Rsdp;

  Status = LocateAndInstallAcpiFromFv (&mJadeAcpiTableFile);
  ASSERT_EFI_ERROR (Status);

  //
  // Find ACPI table RSD_PTR from the system table.
  //
  Status = EfiGetSystemConfigurationTable (&gEfiAcpiTableGuid, (VOID **) &Rsdp);
  if (EFI_ERROR (Status)) {
    Status = EfiGetSystemConfigurationTable (&gEfiAcpi10TableGuid, (VOID **) &Rsdp);
  }

  if (!EFI_ERROR (Status) &&
      Rsdp != NULL &&
      Rsdp->Revision >= EFI_ACPI_2_0_ROOT_SYSTEM_DESCRIPTION_POINTER_REVISION &&
      Rsdp->RsdtAddress != 0) {
    // ARM Platforms must set the RSDT address to NULL
    Rsdp->RsdtAddress = 0;
  }

  DEBUG ((EFI_D_INFO, "[%a:%d]-\n", __FUNCTION__, __LINE__));
}

VOID
EFIAPI
InstallAcpiOnReadyToBoot (
  IN EFI_EVENT        Event,
  IN VOID             *Context
  )
{
  EFI_STATUS Status;

  Status = AcpiInstallMadtTable ();
  if (!EFI_ERROR (Status)) {
    DEBUG ((EFI_D_INFO, "Installed MADT table\n"));
  }

  Status = AcpiInstallPpttTable ();
  if (!EFI_ERROR (Status)) {
    DEBUG ((EFI_D_INFO, "Installed PPTT table\n"));
  }

  Status = AcpiInstallSlitTable ();
  if (!EFI_ERROR (Status)) {
    DEBUG ((EFI_D_INFO, "Installed SLIT table\n"));
  }

  Status = AcpiInstallSratTable ();
  if (!EFI_ERROR (Status)) {
    DEBUG ((EFI_D_INFO, "Installed SRAT table\n"));
  }

  Status = AcpiInstallPcctTable ();
  if (!EFI_ERROR (Status)) {
    DEBUG ((EFI_D_INFO, "Installed PCCT table\n"));
  }

  Status = AcpiInstallNfitTable ();
  if (!EFI_ERROR (Status)) {
    DEBUG ((EFI_D_ERROR, "Installed NFIT table\n"));
  }
}

VOID
EFIAPI
UpdateAcpiOnExitBootServices(
  IN EFI_EVENT        Event,
  IN VOID             *Context
  )
{
  EFI_STATUS  Status;

  Status = AcpiPatchDsdtTable ();
  if (!EFI_ERROR (Status)) {
    DEBUG ((EFI_D_INFO, "DSDT Table updated!\n"));
  }

  // Configure PCC mailbox base address and unmask interrupt
  Status = AcpiPcctInit();
  if (!EFI_ERROR (Status)) {
    DEBUG ((EFI_D_INFO, "PCCT Table updated!\n"));
  }
}

EFI_STATUS
EFIAPI
AcpiPlatformDxeInitialize (
  IN EFI_HANDLE         ImageHandle,
  IN EFI_SYSTEM_TABLE   *SystemTable
  )
{
  EFI_EVENT             ReadyToBootEvent;
  EFI_EVENT             ExitBootServicesEvent;
  EFI_STATUS            Status;

  EfiCreateProtocolNotifyEvent (
    &gEfiAcpiTableProtocolGuid,
    TPL_CALLBACK,
    AcpiNotificationEvent,
    NULL,
    &mAcpiRegistration
    );

  Status = gBS->CreateEvent (
                  EVT_SIGNAL_EXIT_BOOT_SERVICES,
                  TPL_CALLBACK,
                  UpdateAcpiOnExitBootServices,
                  NULL,
                  &ExitBootServicesEvent
                  );
  ASSERT_EFI_ERROR (Status);

  Status = gBS->CreateEventEx (
                  EVT_NOTIFY_SIGNAL,
                  TPL_CALLBACK,
                  InstallAcpiOnReadyToBoot,
                  NULL,
                  &gEfiEventReadyToBootGuid,
                  &ReadyToBootEvent
                  );
  ASSERT_EFI_ERROR(Status);

  return EFI_SUCCESS;
}

/** @file

  Copyright (c) 2020, Ampere Computing LLC. All rights reserved.<BR>

  SPDX-License-Identifier: BSD-2-Clause-Patent

**/

#include <PiPei.h>
#include <Uefi/UefiBaseType.h>
#include <Library/BaseLib.h>
#include <Library/DebugLib.h>
#include <Library/HobLib.h>
#include <Library/PeimEntryPoint.h>
#include <Library/PeiServicesLib.h>
#include <Library/PcdLib.h>
#include <Guid/PlatformInfoHobGuid.h>
#include <PlatformInfoHob.h>

VOID
BuildPlatformInformationHob (
  VOID
  )
{
  VOID  *Hob;

  /* The ATF HOB handoff base is at PcdSystemMemoryBase */
  Hob = GetNextGuidHob (&gPlatformHobGuid, (CONST VOID *) FixedPcdGet64 (PcdSystemMemoryBase));
  /* Build a GUID to pass them Platform HOB data to DXE phase */
  if (Hob) {
    BuildGuidDataHob (&gPlatformHobGuid, GET_GUID_HOB_DATA (Hob), GET_GUID_HOB_DATA_SIZE (Hob));
  }

  Hob = GetNextGuidHob (&gPlatformHobV2Guid, (CONST VOID *) FixedPcdGet64 (PcdSystemMemoryBase));
  if (Hob) {
    BuildGuidDataHob (&gPlatformHobV2Guid, GET_GUID_HOB_DATA (Hob), GET_GUID_HOB_DATA_SIZE (Hob));
  }
}

EFI_STATUS
EFIAPI
InitializeATFHobPeim (
  IN       EFI_PEI_FILE_HANDLE  FileHandle,
  IN CONST EFI_PEI_SERVICES     **PeiServices
  )
{
  BuildPlatformInformationHob ();

  return EFI_SUCCESS;
}

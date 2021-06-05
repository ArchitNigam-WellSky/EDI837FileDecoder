<# To execute

Created by: Archit Nigam
Created on: 5/28/2020

Instructions to execute: 

1. Start Windows PowerShell with the "Run as Administrator" option. Only members of the Administrators group on the computer can change the execution policy.

2. Enable running unsigned scripts by entering:

            set-executionpolicy remotesigned

3. Two parameters are to be passed, -EDIFilePath, i.e. the folder in which your txt file with EDI content is present and -EDIFileName, i.e. the file name of txt.

Note: The script has to be executed in PowerShell Command Prompt.

Sample Command:

.\DecodeEDI837.ps1 -EDIFilePath "C:\Users\architn\Documents" -EDIFileName "SampleEDI837.txt"

#>

Param( 
[Parameter(Mandatory=$true)]
[string] $EDIFilePath, 
[Parameter(Mandatory=$true)]
[string] $EDIFileName
) 
cls
$EDIFile = $EDIFilePath + "\$EDIFileName"

$EDIFileContents = Get-Content $EDIFile 
Write-Host "                                       EDI File Details:"
Write-Host "-----------------------------------------------------------------------------------------------------------------------"
foreach($line in $EDIFileContents)
{

    # Functional Group Header (GS) details
    if ($line -like "GS*HC*") 
    {
        Write-Host ""
        $FunctionalGroupHeader, $FunctionalIDCode, $SenderID, $ReceiverID, $DateOfTransaction, $TimeOfTransaction, $GroupControlNumber, $ResponsibleAgencyCode, $IndustryIDCode = $line -Split {$_ -eq "*" -or $_ -eq "*" -or $_ -eq "*"  -or $_ -eq "*" -or $_ -eq "*" -or $_ -eq "*" -or $_ -eq "*" -or $_ -eq "*" -or $_ -eq "*" -or $_ -eq "~"}
        Write-Host ""
        Write-Host "Sender ID: $SenderID"
        Write-Host ""
        Write-Host "Receiver ID: $ReceiverID"
        Write-Host ""
        Write-Host "Date Of Submission in YYYMMDD format: $DateOfTransaction"
        Write-Host ""
        Write-Host "Time Of Submission in HHHMMSS: $TimeOfTransaction"
        Write-Host ""
        Write-Host "Group Control Number: $GroupControlNumber"
        Write-Host ""
        Write-Host "Responsible Agency Code: $ResponsibleAgencyCode"
        Write-Host ""
        Write-Host "Industry ID Code: $IndustryIDCode"
        Write-Host ""
        Write-Host "-----------------------------------------------------------------------"
    }

    #Vendor details
    if ($line -like "NM1*41*2*")
    {
        Write-Host "Submitter Details"
        Write-Host ""
        $SegmentSubmitterHeader, $SubmitterIdentifierCode,$SegmentTypeQualifier, $SubmitterName, $IdentificationQualifier, $IdentificationCode  = $line -Split {$_ -eq "*" -or $_ -eq "*" -or $_ -eq "*" -or $_ -eq "*" -or $_ -eq "~"}
        Write-Host ""
        Write-Host "Submitter Name: $SubmitterName"
    }

    if ($line -like "PER*IC*") 
    {
        $SubmitterEDIHeader, $ContactFunctionCode,$SubmitterContactName, $CommunicationQualifierNumber, $CommunicationNumber = $line -Split {$_ -eq "*" -or $_ -eq "*" -or $_ -eq "*" -or $_ -eq "*" -or $_ -eq "~"}
        Write-Host ""
        Write-Host "Submitter Contact Name: $SubmitterContactName"
        Write-Host ""
        Write-Host "Submitter Contact Information: $CommunicationNumber"
        Write-Host "-----------------------------------------------------------------------"
    }

    #Claim Receiver Details (Payer)
    if ($line -like "NM1*40*2*") 
    {
        $ReceiverHeader, $ReceiverIdentityCode,$ReceiverIdentificationTypeQualifier, $ReceiverName, $ReceiverIdentificationCodeQualifier, $IdentificationCode = $line -Split {$_ -eq "*" -or $_ -eq "*" -or $_ -eq "*"  -or $_ -eq "*****" -or $_ -eq "*" -or $_ -eq "~"}
        Write-Host ""
        Write-Host "Receiver Name: $ReceiverName"
        Write-Host ""
        Write-Host "-----------------------------------------------------------------------"
    }
    
    # Billing Provider Details
    if ($line -like "NM1*85*")
    {
        $BillingProviderHeader, $BillingProviderIdentityCode,$BillingProviderIdentificationTypeQualifier, $BillingProviderName, $BillingProviderIdentificationCodeQualifier, $VendorNPIAndidentificationCode = $line -Split {$_ -eq "*" -or $_ -eq "*" -or $_ -eq "*"  -or $_ -eq "*****" -or $_ -eq "*" -or $_ -eq "~"}
        Write-Host ""
        Write-Host "Billing Provider Name: $BillingProviderName"
        $Spaces, $VendorNPI, $Rest = $VendorNPIAndidentificationCode -split {$_ -eq "    " -or $_ -eq " " -or $_ -eq " "}
        Write-Host ""
        Write-Host "Vendor NPI: $VendorNPI"
    }

    # Consumer Details
    if ($line -like "NM1*IL*")  
    {
        Write-Host "Subscriber Details"
        $SubscriberHeader, $SubscriberCode, $SubscriberTypeIdentifier, $LastName, $FirstName, $MiddleName, $SubscriberIdentificationTypeQualifier, $SubscriberIdentificationCode = $line -Split {$_ -eq "*" -or $_ -eq "*" -or $_ -eq "*"  -or $_ -eq "*" -or $_ -eq "****" -or $_ -eq "~"}
        Write-Host ""
        Write-Host "Subscriber Last Name: $LastName"
        Write-Host ""
        Write-Host "Subscriber First Name: $FirstName"
    }
    if ($line -like "N3*")  
    {
        $StreetGroupHeader, $Street = $line -Split {$_ -eq "*" -or $_ -eq "~"}
        Write-Host ""
        Write-Host "Street: $Street"
        Write-Host ""
    }
    if ($line -like "N4*")  
    {
        $StateGroupHeader, $City, $State, $ZipCode = $line -Split {$_ -eq "*" -or $_ -eq "*" -or $_ -eq "*" -or $_ -eq "~"}
        Write-Host "City: $City"
        Write-Host ""
        Write-Host "State: $State"
        Write-Host ""
        Write-Host "Zip Code: $ZipCode"
        Write-Host ""
    }
    if($line -like "REF*EI*")
    {
        $ProviderNumberHeader, $ProviderNumberSegmentHeader, $EIN = $line -Split {$_ -eq "*" -or $_ -eq "*" -or $_ -eq "*" -or $_ -eq "~"}
        Write-host "Employee Identification Number: $EIN"
        Write-Host "-----------------------------------------------------------------------"
    }
    if ($line -like "DMG*D8*")
    {
        $DemographicSegmentHeader, $DemographicSegmentCode, $SubscriberDateOfBirth, $Gender = $line -Split {$_ -eq "*" -or $_ -eq "*" -or $_ -eq "*" -or $_ -eq "~"}
        Write-Host "Subscriber Date Of Birth in YYYMMDD format: $SubscriberDateOfBirth"
        Write-Host ""
        Write-Host "Gender: $Gender"
        Write-Host ""
        Write-Host "-----------------------------------------------------------------------"
    }

    #Payer Name
    if ($line -like "SBR*P*") 
    {
        $PayerHeader, $PayerResponsibilitySequence, $PayerIndividualRelationshipCode, $SomeCode, $PayerName, $ClaimFillingIndicatorCode = $line -Split {$_ -eq "*" -or $_ -eq "*" -or $_ -eq "**"  -or $_ -eq "*****" -or $_ -eq "~"}
        Write-Host ""
        Write-Host "Payer Name: $PayerName"
        Write-Host ""
        Write-Host "-----------------------------------------------------------------------"
    }

    # Payer Organization Name 
   if ($line -like "NM1*PR*2*") 
    {
        $PayerOrganizationHeader, $PayerIdentifierCode, $PayeridentifierQualifier, $PayerOrganizationName, $PayerIdentificationCode = $line -Split {$_ -eq "*" -or $_ -eq "*" -or $_ -eq "*"  -or $_ -eq "*****" -or $_ -eq "*" -or $_ -eq "~"}
        Write-Host ""
        Write-Host "Payer Organization Name: $PayerOrganizationName"
        Write-Host ""
        Write-Host "-----------------------------------------------------------------------"
    }
    if($line -like "REF*EA*")
    {
         $PayerClaimControlHeader, $PayerClaimControlSegmentHeader, $PayerClaimControlNumber = $line -Split {$_ -eq "*" -or $_ -eq "*" -or $_ -eq "*" -or $_ -eq "~"}
         Write-Host ""
         Write-Host "Consumer Number/Payer Claim Control Number: $PayerClaimControlNumber"
    }
    # Claim Details
    if ($line -like "CLM*") 
    {
        Write-Host "Claim Details"
        $ClaimGroupHeader, $ClaimSubmitterIdentifier,$MonetaryAmount, $ServiceLocation, $FacilityCodeValue, $FrequencyTypeCode, $ReasonCode = $line -Split {$_ -eq "*" -or $_ -eq "*" -or $_ -eq "*"  -or $_ -eq "*****" -or $_ -eq "*" -or $_ -eq "~"}
        Write-Host ""
        Write-Host "Claim Amount:$ $MonetaryAmount"
        
    }
     if ($line -like "SV1*") 
    {
        $ServiceGroupHeader, $ServiceGroupCode, $ServiceCode, $Modifier, $Units, $Quantity, $Something = $line -Split {$_ -eq "*" -or $_ -eq ":" -or $_ -eq ":" -or $_ -eq "*"  -or $_ -eq "*****" -or $_ -eq "*" -or $_ -eq "~"}
        Write-Host ""
        Write-Host "Service Code: $ServiceCode"
        Write-Host ""
        Write-Host "Units: $Units"
        Write-Host ""
         Write-Host "Quantity: $Quantity"
        Write-Host ""
        Write-Host "Service Cost:$ $MonetaryAmount"
        
    }
     if ($line -like "DTP*472**") 
    {
        $ServiceDateGroupHeader, $GroupCode, $SomeCode, $StartDate, $EndDate, $Units, $IndustryIDCode, $Something = $line -Split {$_ -eq "*" -or $_ -eq "*" -or $_ -eq "*"  -or $_ -eq "-" -or $_ -eq "*" -or $_ -eq "~"}
        Write-Host ""
        Write-Host "Start Date in YYYMMDD format: $StartDate"
        Write-Host ""
        Write-Host "End Date in YYYMMDD format: $EndDate"
        Write-Host ""
        Write-Host "-----------------------------------------------------------------------"  
    }
    if($line -like "SE*")
    {
     $TransactionSetHeader, $TransactionSetSegmentHeader, $ClaimStatusID = $line -Split {$_ -eq "*" -or $_ -eq "*" -or $_ -eq "*" -or $_ -eq "~"}
     Write-Host ""
     Write-Host "Claim Status ID: $ClaimStatusID"
     Write-Host ""
     Write-Host "-----------------------------------------------------------------------" 

    }
}
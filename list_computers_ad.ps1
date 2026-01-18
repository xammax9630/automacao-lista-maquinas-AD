<#
.SYNOPSIS
Script para listar computadores em uma Unidade Organizacional do Active Directory e exportar para CSV.

.DESCRIPTION
Este script utiliza Get-ADComputer para recuperar objetos de computador em uma unidade organizacional especifica (OU) no Active Directory.
Coleta propriedades como Name,OperatingSystem,LastLogonDate e DistinguishedName, e exporta os resultados para um arquivo CSV.

.PARAMETER OU
Nome distinto (Distinguished Name) da Unidade Organizacional a ser pesquisada. Exemplo: "OU=Computers,DC=empresa,DC=local".

.PARAMETER OutputPath
Caminho do arquivo CSV a ser gerado. Se omitido, o script cria um arquivo "computers_<data>.csv" no diretório atual.

.EXAMPLE
.\list_computers_ad.ps1 -OU "OU=Computers,DC=empresa,DC=local" -OutputPath "C:\Temp\computadores.csv"

# Criado em 2026-01-18
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$OU,

    [Parameter(Mandatory=$false)]
    [string]$OutputPath
)

# Verifica se o módulo ActiveDirectory está disponível
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "O módulo ActiveDirectory não está instalado. Instale RSAT ou importe o módulo."
    exit 1
}

# Define caminho padrão caso não seja fornecido
if (-not $OutputPath) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $OutputPath = Join-Path -Path (Get-Location) -ChildPath "computers_$timestamp.csv"
}

try {
    # Recupera computadores na OU especificada
    $computers = Get-ADComputer -SearchBase $OU -Filter * -Properties Name,OperatingSystem,LastLogonDate,DistinguishedName |
        Select-Object Name,OperatingSystem,LastLogonDate,DistinguishedName

    if ($computers.Count -eq 0) {
        Write-Warning "Nenhum computador encontrado em $OU"
    } else {
        # Exporta para CSV
        $computers | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
        Write-Output "Exportado $($computers.Count) computadores para: $OutputPath"
    }
} catch {
    Write-Error "Erro ao recuperar computadores: $_"
}

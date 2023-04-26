# MARCEdit Tasks

Definitions of the `.task` files used to prepare MARC files for [HathiTrust ingest](/Hathi_Trust/Hathi_trust_tasks.task)

## basics_for_hathi

- adds `003 IEN`
- adds `040 $c INU` if no `$c` exists
- changes `590` to `500`
- deletes `852`, `856`

## 035_Voyager_Step1

- deletes (`NU` or `TR`) from end of `035 $a`

## 035_Voyager_Step2

- removes `-nuwdb` from `035`
- changes `035 $a(IEN)` to `$z(IEN)Voyager`
- removes `035 $z` that contains: `(set by OCLC ; Added by OCLC; added by program)`

## indicator_corrections

| field | old indicator | new indicator |
|---|---|---|
| 050 | `\\` | `\4` |
| 050 | `0\` | `00` |
| 060 | `0\` | `00` |
| 082 | `\_` | `0_` |
| 100 | `00` | `0\` |
| 100 | `10` | `1\` |
| 100 | `2\` | `1\` |
| 100 | `20` | `1\` |
| 110 | `10` | `1\` |
| 110 | `20` | `2\` |
| 111 | `20` | `2\` |
| 130 | `00` | `0\` |
| 260 | `0\` | `\\` |
| 260 | `00` | `\\` |
| 260 | `1\` | `\\` |
| 260 | `10` | `\\` |
| 600 | `20` | `10` |
| 700 | `00` | `02` |
| 700 | `01` | `0\` |
| 700 | `10` | `1\` |
| 700 | `11` | `1\` |
| 700 | `2\` | `1\` |
| 700 | `20` | `1\` |
| 700 | `30` | `3\` |
| 700 | `31` | `3\` |
| 710 | `10` | `1\` |
| 710 | `11` | `12` |
| 710 | `20` | `2\` |
| 710 | `21` | `2\` |
| 711 | `20` | `2\` |
| 730 | `00` | `02` |
| 730 | `01` | `02` |
| 740 | `00` | `02` |
| 740 | `01` | `02` |
| 740 | `21` | `22` |
| 740 | `31` | `32` |
| 740 | `41` | `42` |

## Remove extra fields

- removes `9XX`
- removes `850`, `852`, `866`
- removes `019`
- removes `035 $z(OCoLC) ; Added by OCLC` ; `set by OCLC` ; `added by program`

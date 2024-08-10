library iso4217_currencies;

import 'package:flow/utils/utils.dart';

class CurrencyData {
  /// Three letter [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217) currency code
  final String code;

  /// Country in which the currency is used (in English)
  final String country;

  /// Name of the currency (in English)
  final String name;

  const CurrencyData({
    required this.code,
    required this.country,
    required this.name,
  });
}

/// All data is retreived from <http://www.currency-iso.org/en/home/tables/table-a1.html>
///
/// Last updated: 29 Dec 2023 by @sadespresso
///
/// List of excluded entries:
/// * **Any currency with no currency code**
/// * XBA - Bond Markets Unit European Composite Unit (EURCO) (ZZ01_Bond Markets Unit European_EURCO)
/// * XBB - Bond Markets Unit European Monetary Unit (E.M.U.-6) (ZZ02_Bond Markets Unit European_EMU-6)
/// * XBC - Bond Markets Unit European Unit of Account 9 (E.U.A.-9) (ZZ03_Bond Markets Unit European_EUA-9)
/// * XBD - Bond Markets Unit European Unit of Account 17 (E.U.A.-17) (ZZ04_Bond Markets Unit European_EUA-17)
/// * XTS - Codes specifically reserved for testing purposes (ZZ06_Testing_Code)
/// * XXX - The codes assigned for transactions where no currency is involved (ZZ07_No_Currency)
/// * XAU - Gold (ZZ08_Gold)
/// * XPD - Palladium (ZZ09_Palladium)
/// * XPT - Platinum (ZZ10_Platinum)
/// * XAG - Silver (ZZ11_Silver)
final List<CurrencyData> iso4217Currencies = [
  const CurrencyData(
    country: "AFGHANISTAN",
    name: "Afghani",
    code: "AFN",
  ),
  const CurrencyData(
    country: "ÅLAND ISLANDS",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "ALBANIA",
    name: "Lek",
    code: "ALL",
  ),
  const CurrencyData(
    country: "ALGERIA",
    name: "Algerian Dinar",
    code: "DZD",
  ),
  const CurrencyData(
    country: "AMERICAN SAMOA",
    name: "US Dollar",
    code: "USD",
  ),
  const CurrencyData(
    country: "ANDORRA",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "ANGOLA",
    name: "Kwanza",
    code: "AOA",
  ),
  const CurrencyData(
    country: "ANGUILLA",
    name: "East Caribbean Dollar",
    code: "XCD",
  ),
  const CurrencyData(
    country: "ANTIGUA AND BARBUDA",
    name: "East Caribbean Dollar",
    code: "XCD",
  ),
  const CurrencyData(
    country: "ARGENTINA",
    name: "Argentine Peso",
    code: "ARS",
  ),
  const CurrencyData(
    country: "ARMENIA",
    name: "Armenian Dram",
    code: "AMD",
  ),
  const CurrencyData(
    country: "ARUBA",
    name: "Aruban Florin",
    code: "AWG",
  ),
  const CurrencyData(
    country: "AUSTRALIA",
    name: "Australian Dollar",
    code: "AUD",
  ),
  const CurrencyData(
    country: "AUSTRIA",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "AZERBAIJAN",
    name: "Azerbaijan Manat",
    code: "AZN",
  ),
  const CurrencyData(
    country: "BAHAMAS (THE)",
    name: "Bahamian Dollar",
    code: "BSD",
  ),
  const CurrencyData(
    country: "BAHRAIN",
    name: "Bahraini Dinar",
    code: "BHD",
  ),
  const CurrencyData(
    country: "BANGLADESH",
    name: "Taka",
    code: "BDT",
  ),
  const CurrencyData(
    country: "BARBADOS",
    name: "Barbados Dollar",
    code: "BBD",
  ),
  const CurrencyData(
    country: "BELARUS",
    name: "Belarusian Ruble",
    code: "BYN",
  ),
  const CurrencyData(
    country: "BELGIUM",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "BELIZE",
    name: "Belize Dollar",
    code: "BZD",
  ),
  const CurrencyData(
    country: "BENIN",
    name: "CFA Franc BCEAO",
    code: "XOF",
  ),
  const CurrencyData(
    country: "BERMUDA",
    name: "Bermudian Dollar",
    code: "BMD",
  ),
  const CurrencyData(
    country: "BHUTAN",
    name: "Indian Rupee",
    code: "INR",
  ),
  const CurrencyData(
    country: "BHUTAN",
    name: "Ngultrum",
    code: "BTN",
  ),
  const CurrencyData(
    country: "BOLIVIA (PLURINATIONAL STATE OF)",
    name: "Boliviano",
    code: "BOB",
  ),
  const CurrencyData(
    country: "BOLIVIA (PLURINATIONAL STATE OF)",
    name: "Mvdol",
    code: "BOV",
  ),
  const CurrencyData(
    country: "BONAIRE, SINT EUSTATIUS AND SABA",
    name: "US Dollar",
    code: "USD",
  ),
  const CurrencyData(
    country: "BOSNIA AND HERZEGOVINA",
    name: "Convertible Mark",
    code: "BAM",
  ),
  const CurrencyData(
    country: "BOTSWANA",
    name: "Pula",
    code: "BWP",
  ),
  const CurrencyData(
    country: "BOUVET ISLAND",
    name: "Norwegian Krone",
    code: "NOK",
  ),
  const CurrencyData(
    country: "BRAZIL",
    name: "Brazilian Real",
    code: "BRL",
  ),
  const CurrencyData(
    country: "BRITISH INDIAN OCEAN TERRITORY (THE)",
    name: "US Dollar",
    code: "USD",
  ),
  const CurrencyData(
    country: "BRUNEI DARUSSALAM",
    name: "Brunei Dollar",
    code: "BND",
  ),
  const CurrencyData(
    country: "BULGARIA",
    name: "Bulgarian Lev",
    code: "BGN",
  ),
  const CurrencyData(
    country: "BURKINA FASO",
    name: "CFA Franc BCEAO",
    code: "XOF",
  ),
  const CurrencyData(
    country: "BURUNDI",
    name: "Burundi Franc",
    code: "BIF",
  ),
  const CurrencyData(
    country: "CABO VERDE",
    name: "Cabo Verde Escudo",
    code: "CVE",
  ),
  const CurrencyData(
    country: "CAMBODIA",
    name: "Riel",
    code: "KHR",
  ),
  const CurrencyData(
    country: "CAMEROON",
    name: "CFA Franc BEAC",
    code: "XAF",
  ),
  const CurrencyData(
    country: "CANADA",
    name: "Canadian Dollar",
    code: "CAD",
  ),
  const CurrencyData(
    country: "CAYMAN ISLANDS (THE)",
    name: "Cayman Islands Dollar",
    code: "KYD",
  ),
  const CurrencyData(
    country: "CENTRAL AFRICAN REPUBLIC (THE)",
    name: "CFA Franc BEAC",
    code: "XAF",
  ),
  const CurrencyData(
    country: "CHAD",
    name: "CFA Franc BEAC",
    code: "XAF",
  ),
  const CurrencyData(
    country: "CHILE",
    name: "Chilean Peso",
    code: "CLP",
  ),
  const CurrencyData(
    country: "CHILE",
    name: "Unidad de Fomento",
    code: "CLF",
  ),
  const CurrencyData(
    country: "CHINA",
    name: "Yuan Renminbi",
    code: "CNY",
  ),
  const CurrencyData(
    country: "CHRISTMAS ISLAND",
    name: "Australian Dollar",
    code: "AUD",
  ),
  const CurrencyData(
    country: "COCOS (KEELING) ISLANDS (THE)",
    name: "Australian Dollar",
    code: "AUD",
  ),
  const CurrencyData(
    country: "COLOMBIA",
    name: "Colombian Peso",
    code: "COP",
  ),
  const CurrencyData(
    country: "COLOMBIA",
    name: "Unidad de Valor Real",
    code: "COU",
  ),
  const CurrencyData(
    country: "COMOROS (THE)",
    name: "Comorian Franc",
    code: "KMF",
  ),
  const CurrencyData(
    country: "CONGO (THE DEMOCRATIC REPUBLIC OF THE)",
    name: "Congolese Franc",
    code: "CDF",
  ),
  const CurrencyData(
    country: "CONGO (THE)",
    name: "CFA Franc BEAC",
    code: "XAF",
  ),
  const CurrencyData(
    country: "COOK ISLANDS (THE)",
    name: "New Zealand Dollar",
    code: "NZD",
  ),
  const CurrencyData(
    country: "COSTA RICA",
    name: "Costa Rican Colon",
    code: "CRC",
  ),
  const CurrencyData(
    country: "CÔTE D'IVOIRE",
    name: "CFA Franc BCEAO",
    code: "XOF",
  ),
  const CurrencyData(
    country: "CROATIA",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "CUBA",
    name: "Cuban Peso",
    code: "CUP",
  ),
  const CurrencyData(
    country: "CUBA",
    name: "Peso Convertible",
    code: "CUC",
  ),
  const CurrencyData(
    country: "CURAÇAO",
    name: "Netherlands Antillean Guilder",
    code: "ANG",
  ),
  const CurrencyData(
    country: "CYPRUS",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "CZECHIA",
    name: "Czech Koruna",
    code: "CZK",
  ),
  const CurrencyData(
    country: "DENMARK",
    name: "Danish Krone",
    code: "DKK",
  ),
  const CurrencyData(
    country: "DJIBOUTI",
    name: "Djibouti Franc",
    code: "DJF",
  ),
  const CurrencyData(
    country: "DOMINICA",
    name: "East Caribbean Dollar",
    code: "XCD",
  ),
  const CurrencyData(
    country: "DOMINICAN REPUBLIC (THE)",
    name: "Dominican Peso",
    code: "DOP",
  ),
  const CurrencyData(
    country: "ECUADOR",
    name: "US Dollar",
    code: "USD",
  ),
  const CurrencyData(
    country: "EGYPT",
    name: "Egyptian Pound",
    code: "EGP",
  ),
  const CurrencyData(
    country: "EL SALVADOR",
    name: "El Salvador Colon",
    code: "SVC",
  ),
  const CurrencyData(
    country: "EL SALVADOR",
    name: "US Dollar",
    code: "USD",
  ),
  const CurrencyData(
    country: "EQUATORIAL GUINEA",
    name: "CFA Franc BEAC",
    code: "XAF",
  ),
  const CurrencyData(
    country: "ERITREA",
    name: "Nakfa",
    code: "ERN",
  ),
  const CurrencyData(
    country: "ESTONIA",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "ESWATINI",
    name: "Lilangeni",
    code: "SZL",
  ),
  const CurrencyData(
    country: "ETHIOPIA",
    name: "Ethiopian Birr",
    code: "ETB",
  ),
  const CurrencyData(
    country: "EUROPEAN UNION",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "FALKLAND ISLANDS (THE) [MALVINAS]",
    name: "Falkland Islands Pound",
    code: "FKP",
  ),
  const CurrencyData(
    country: "FAROE ISLANDS (THE)",
    name: "Danish Krone",
    code: "DKK",
  ),
  const CurrencyData(
    country: "FIJI",
    name: "Fiji Dollar",
    code: "FJD",
  ),
  const CurrencyData(
    country: "FINLAND",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "FRANCE",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "FRENCH GUIANA",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "FRENCH POLYNESIA",
    name: "CFP Franc",
    code: "XPF",
  ),
  const CurrencyData(
    country: "FRENCH SOUTHERN TERRITORIES (THE)",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "GABON",
    name: "CFA Franc BEAC",
    code: "XAF",
  ),
  const CurrencyData(
    country: "GAMBIA (THE)",
    name: "Dalasi",
    code: "GMD",
  ),
  const CurrencyData(
    country: "GEORGIA",
    name: "Lari",
    code: "GEL",
  ),
  const CurrencyData(
    country: "GERMANY",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "GHANA",
    name: "Ghana Cedi",
    code: "GHS",
  ),
  const CurrencyData(
    country: "GIBRALTAR",
    name: "Gibraltar Pound",
    code: "GIP",
  ),
  const CurrencyData(
    country: "GREECE",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "GREENLAND",
    name: "Danish Krone",
    code: "DKK",
  ),
  const CurrencyData(
    country: "GRENADA",
    name: "East Caribbean Dollar",
    code: "XCD",
  ),
  const CurrencyData(
    country: "GUADELOUPE",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "GUAM",
    name: "US Dollar",
    code: "USD",
  ),
  const CurrencyData(
    country: "GUATEMALA",
    name: "Quetzal",
    code: "GTQ",
  ),
  const CurrencyData(
    country: "GUERNSEY",
    name: "Pound Sterling",
    code: "GBP",
  ),
  const CurrencyData(
    country: "GUINEA",
    name: "Guinean Franc",
    code: "GNF",
  ),
  const CurrencyData(
    country: "GUINEA-BISSAU",
    name: "CFA Franc BCEAO",
    code: "XOF",
  ),
  const CurrencyData(
    country: "GUYANA",
    name: "Guyana Dollar",
    code: "GYD",
  ),
  const CurrencyData(
    country: "HAITI",
    name: "Gourde",
    code: "HTG",
  ),
  const CurrencyData(
    country: "HAITI",
    name: "US Dollar",
    code: "USD",
  ),
  const CurrencyData(
    country: "HEARD ISLAND AND McDONALD ISLANDS",
    name: "Australian Dollar",
    code: "AUD",
  ),
  const CurrencyData(
    country: "HOLY SEE (THE)",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "HONDURAS",
    name: "Lempira",
    code: "HNL",
  ),
  const CurrencyData(
    country: "HONG KONG",
    name: "Hong Kong Dollar",
    code: "HKD",
  ),
  const CurrencyData(
    country: "HUNGARY",
    name: "Forint",
    code: "HUF",
  ),
  const CurrencyData(
    country: "ICELAND",
    name: "Iceland Krona",
    code: "ISK",
  ),
  const CurrencyData(
    country: "INDIA",
    name: "Indian Rupee",
    code: "INR",
  ),
  const CurrencyData(
    country: "INDONESIA",
    name: "Rupiah",
    code: "IDR",
  ),
  const CurrencyData(
    country: "INTERNATIONAL MONETARY FUND (IMF) ",
    name: "SDR (Special Drawing Right)",
    code: "XDR",
  ),
  const CurrencyData(
    country: "IRAN (ISLAMIC REPUBLIC OF)",
    name: "Iranian Rial",
    code: "IRR",
  ),
  const CurrencyData(
    country: "IRAQ",
    name: "Iraqi Dinar",
    code: "IQD",
  ),
  const CurrencyData(
    country: "IRELAND",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "ISLE OF MAN",
    name: "Pound Sterling",
    code: "GBP",
  ),
  const CurrencyData(
    country: "ISRAEL",
    name: "New Israeli Sheqel",
    code: "ILS",
  ),
  const CurrencyData(
    country: "ITALY",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "JAMAICA",
    name: "Jamaican Dollar",
    code: "JMD",
  ),
  const CurrencyData(
    country: "JAPAN",
    name: "Yen",
    code: "JPY",
  ),
  const CurrencyData(
    country: "JERSEY",
    name: "Pound Sterling",
    code: "GBP",
  ),
  const CurrencyData(
    country: "JORDAN",
    name: "Jordanian Dinar",
    code: "JOD",
  ),
  const CurrencyData(
    country: "KAZAKHSTAN",
    name: "Tenge",
    code: "KZT",
  ),
  const CurrencyData(
    country: "KENYA",
    name: "Kenyan Shilling",
    code: "KES",
  ),
  const CurrencyData(
    country: "KIRIBATI",
    name: "Australian Dollar",
    code: "AUD",
  ),
  const CurrencyData(
    country: "KOREA (THE DEMOCRATIC PEOPLE’S REPUBLIC OF)",
    name: "North Korean Won",
    code: "KPW",
  ),
  const CurrencyData(
    country: "KOREA (THE REPUBLIC OF)",
    name: "Won",
    code: "KRW",
  ),
  const CurrencyData(
    country: "KUWAIT",
    name: "Kuwaiti Dinar",
    code: "KWD",
  ),
  const CurrencyData(
    country: "KYRGYZSTAN",
    name: "Som",
    code: "KGS",
  ),
  const CurrencyData(
    country: "LAO PEOPLE’S DEMOCRATIC REPUBLIC (THE)",
    name: "Lao Kip",
    code: "LAK",
  ),
  const CurrencyData(
    country: "LATVIA",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "LEBANON",
    name: "Lebanese Pound",
    code: "LBP",
  ),
  const CurrencyData(
    country: "LESOTHO",
    name: "Loti",
    code: "LSL",
  ),
  const CurrencyData(
    country: "LESOTHO",
    name: "Rand",
    code: "ZAR",
  ),
  const CurrencyData(
    country: "LIBERIA",
    name: "Liberian Dollar",
    code: "LRD",
  ),
  const CurrencyData(
    country: "LIBYA",
    name: "Libyan Dinar",
    code: "LYD",
  ),
  const CurrencyData(
    country: "LIECHTENSTEIN",
    name: "Swiss Franc",
    code: "CHF",
  ),
  const CurrencyData(
    country: "LITHUANIA",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "LUXEMBOURG",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "MACAO",
    name: "Pataca",
    code: "MOP",
  ),
  const CurrencyData(
    country: "NORTH MACEDONIA",
    name: "Denar",
    code: "MKD",
  ),
  const CurrencyData(
    country: "MADAGASCAR",
    name: "Malagasy Ariary",
    code: "MGA",
  ),
  const CurrencyData(
    country: "MALAWI",
    name: "Malawi Kwacha",
    code: "MWK",
  ),
  const CurrencyData(
    country: "MALAYSIA",
    name: "Malaysian Ringgit",
    code: "MYR",
  ),
  const CurrencyData(
    country: "MALDIVES",
    name: "Rufiyaa",
    code: "MVR",
  ),
  const CurrencyData(
    country: "MALI",
    name: "CFA Franc BCEAO",
    code: "XOF",
  ),
  const CurrencyData(
    country: "MALTA",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "MARSHALL ISLANDS (THE)",
    name: "US Dollar",
    code: "USD",
  ),
  const CurrencyData(
    country: "MARTINIQUE",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "MAURITANIA",
    name: "Ouguiya",
    code: "MRU",
  ),
  const CurrencyData(
    country: "MAURITIUS",
    name: "Mauritius Rupee",
    code: "MUR",
  ),
  const CurrencyData(
    country: "MAYOTTE",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "MEMBER COUNTRIES OF THE AFRICAN DEVELOPMENT BANK GROUP",
    name: "ADB Unit of Account",
    code: "XUA",
  ),
  const CurrencyData(
    country: "MEXICO",
    name: "Mexican Peso",
    code: "MXN",
  ),
  const CurrencyData(
    country: "MEXICO",
    name: "Mexican Unidad de Inversion (UDI)",
    code: "MXV",
  ),
  const CurrencyData(
    country: "MICRONESIA (FEDERATED STATES OF)",
    name: "US Dollar",
    code: "USD",
  ),
  const CurrencyData(
    country: "MOLDOVA (THE REPUBLIC OF)",
    name: "Moldovan Leu",
    code: "MDL",
  ),
  const CurrencyData(
    country: "MONACO",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "MONGOLIA",
    name: "Tugrik",
    code: "MNT",
  ),
  const CurrencyData(
    country: "MONTENEGRO",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "MONTSERRAT",
    name: "East Caribbean Dollar",
    code: "XCD",
  ),
  const CurrencyData(
    country: "MOROCCO",
    name: "Moroccan Dirham",
    code: "MAD",
  ),
  const CurrencyData(
    country: "MOZAMBIQUE",
    name: "Mozambique Metical",
    code: "MZN",
  ),
  const CurrencyData(
    country: "MYANMAR",
    name: "Kyat",
    code: "MMK",
  ),
  const CurrencyData(
    country: "NAMIBIA",
    name: "Namibia Dollar",
    code: "NAD",
  ),
  const CurrencyData(
    country: "NAMIBIA",
    name: "Rand",
    code: "ZAR",
  ),
  const CurrencyData(
    country: "NAURU",
    name: "Australian Dollar",
    code: "AUD",
  ),
  const CurrencyData(
    country: "NEPAL",
    name: "Nepalese Rupee",
    code: "NPR",
  ),
  const CurrencyData(
    country: "NETHERLANDS (THE)",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "NEW CALEDONIA",
    name: "CFP Franc",
    code: "XPF",
  ),
  const CurrencyData(
    country: "NEW ZEALAND",
    name: "New Zealand Dollar",
    code: "NZD",
  ),
  const CurrencyData(
    country: "NICARAGUA",
    name: "Cordoba Oro",
    code: "NIO",
  ),
  const CurrencyData(
    country: "NIGER (THE)",
    name: "CFA Franc BCEAO",
    code: "XOF",
  ),
  const CurrencyData(
    country: "NIGERIA",
    name: "Naira",
    code: "NGN",
  ),
  const CurrencyData(
    country: "NIUE",
    name: "New Zealand Dollar",
    code: "NZD",
  ),
  const CurrencyData(
    country: "NORFOLK ISLAND",
    name: "Australian Dollar",
    code: "AUD",
  ),
  const CurrencyData(
    country: "NORTHERN MARIANA ISLANDS (THE)",
    name: "US Dollar",
    code: "USD",
  ),
  const CurrencyData(
    country: "NORWAY",
    name: "Norwegian Krone",
    code: "NOK",
  ),
  const CurrencyData(
    country: "OMAN",
    name: "Rial Omani",
    code: "OMR",
  ),
  const CurrencyData(
    country: "PAKISTAN",
    name: "Pakistan Rupee",
    code: "PKR",
  ),
  const CurrencyData(
    country: "PALAU",
    name: "US Dollar",
    code: "USD",
  ),
  const CurrencyData(
    country: "PANAMA",
    name: "Balboa",
    code: "PAB",
  ),
  const CurrencyData(
    country: "PANAMA",
    name: "US Dollar",
    code: "USD",
  ),
  const CurrencyData(
    country: "PAPUA NEW GUINEA",
    name: "Kina",
    code: "PGK",
  ),
  const CurrencyData(
    country: "PARAGUAY",
    name: "Guarani",
    code: "PYG",
  ),
  const CurrencyData(
    country: "PERU",
    name: "Sol",
    code: "PEN",
  ),
  const CurrencyData(
    country: "PHILIPPINES (THE)",
    name: "Philippine Peso",
    code: "PHP",
  ),
  const CurrencyData(
    country: "PITCAIRN",
    name: "New Zealand Dollar",
    code: "NZD",
  ),
  const CurrencyData(
    country: "POLAND",
    name: "Zloty",
    code: "PLN",
  ),
  const CurrencyData(
    country: "PORTUGAL",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "PUERTO RICO",
    name: "US Dollar",
    code: "USD",
  ),
  const CurrencyData(
    country: "QATAR",
    name: "Qatari Rial",
    code: "QAR",
  ),
  const CurrencyData(
    country: "RÉUNION",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "ROMANIA",
    name: "Romanian Leu",
    code: "RON",
  ),
  const CurrencyData(
    country: "RUSSIAN FEDERATION (THE)",
    name: "Russian Ruble",
    code: "RUB",
  ),
  const CurrencyData(
    country: "RWANDA",
    name: "Rwanda Franc",
    code: "RWF",
  ),
  const CurrencyData(
    country: "SAINT BARTHÉLEMY",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "SAINT HELENA, ASCENSION AND TRISTAN DA CUNHA",
    name: "Saint Helena Pound",
    code: "SHP",
  ),
  const CurrencyData(
    country: "SAINT KITTS AND NEVIS",
    name: "East Caribbean Dollar",
    code: "XCD",
  ),
  const CurrencyData(
    country: "SAINT LUCIA",
    name: "East Caribbean Dollar",
    code: "XCD",
  ),
  const CurrencyData(
    country: "SAINT MARTIN (FRENCH PART)",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "SAINT PIERRE AND MIQUELON",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "SAINT VINCENT AND THE GRENADINES",
    name: "East Caribbean Dollar",
    code: "XCD",
  ),
  const CurrencyData(
    country: "SAMOA",
    name: "Tala",
    code: "WST",
  ),
  const CurrencyData(
    country: "SAN MARINO",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "SAO TOME AND PRINCIPE",
    name: "Dobra",
    code: "STN",
  ),
  const CurrencyData(
    country: "SAUDI ARABIA",
    name: "Saudi Riyal",
    code: "SAR",
  ),
  const CurrencyData(
    country: "SENEGAL",
    name: "CFA Franc BCEAO",
    code: "XOF",
  ),
  const CurrencyData(
    country: "SERBIA",
    name: "Serbian Dinar",
    code: "RSD",
  ),
  const CurrencyData(
    country: "SEYCHELLES",
    name: "Seychelles Rupee",
    code: "SCR",
  ),
  const CurrencyData(
    country: "SIERRA LEONE",
    name: "Leone",
    code: "SLL",
  ),
  const CurrencyData(
    country: "SIERRA LEONE",
    name: "Leone",
    code: "SLE",
  ),
  const CurrencyData(
    country: "SINGAPORE",
    name: "Singapore Dollar",
    code: "SGD",
  ),
  const CurrencyData(
    country: "SINT MAARTEN (DUTCH PART)",
    name: "Netherlands Antillean Guilder",
    code: "ANG",
  ),
  const CurrencyData(
    country: "SISTEMA UNITARIO DE COMPENSACION REGIONAL DE PAGOS \"SUCRE\"",
    name: "Sucre",
    code: "XSU",
  ),
  const CurrencyData(
    country: "SLOVAKIA",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "SLOVENIA",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "SOLOMON ISLANDS",
    name: "Solomon Islands Dollar",
    code: "SBD",
  ),
  const CurrencyData(
    country: "SOMALIA",
    name: "Somali Shilling",
    code: "SOS",
  ),
  const CurrencyData(
    country: "SOUTH AFRICA",
    name: "Rand",
    code: "ZAR",
  ),
  const CurrencyData(
    country: "SOUTH SUDAN",
    name: "South Sudanese Pound",
    code: "SSP",
  ),
  const CurrencyData(
    country: "SPAIN",
    name: "Euro",
    code: "EUR",
  ),
  const CurrencyData(
    country: "SRI LANKA",
    name: "Sri Lanka Rupee",
    code: "LKR",
  ),
  const CurrencyData(
    country: "SUDAN (THE)",
    name: "Sudanese Pound",
    code: "SDG",
  ),
  const CurrencyData(
    country: "SURINAME",
    name: "Surinam Dollar",
    code: "SRD",
  ),
  const CurrencyData(
    country: "SVALBARD AND JAN MAYEN",
    name: "Norwegian Krone",
    code: "NOK",
  ),
  const CurrencyData(
    country: "SWEDEN",
    name: "Swedish Krona",
    code: "SEK",
  ),
  const CurrencyData(
    country: "SWITZERLAND",
    name: "Swiss Franc",
    code: "CHF",
  ),
  const CurrencyData(
    country: "SWITZERLAND",
    name: "WIR Euro",
    code: "CHE",
  ),
  const CurrencyData(
    country: "SWITZERLAND",
    name: "WIR Franc",
    code: "CHW",
  ),
  const CurrencyData(
    country: "SYRIAN ARAB REPUBLIC",
    name: "Syrian Pound",
    code: "SYP",
  ),
  const CurrencyData(
    country: "TAIWAN (PROVINCE OF CHINA)",
    name: "New Taiwan Dollar",
    code: "TWD",
  ),
  const CurrencyData(
    country: "TAJIKISTAN",
    name: "Somoni",
    code: "TJS",
  ),
  const CurrencyData(
    country: "TANZANIA, UNITED REPUBLIC OF",
    name: "Tanzanian Shilling",
    code: "TZS",
  ),
  const CurrencyData(
    country: "THAILAND",
    name: "Baht",
    code: "THB",
  ),
  const CurrencyData(
    country: "TIMOR-LESTE",
    name: "US Dollar",
    code: "USD",
  ),
  const CurrencyData(
    country: "TOGO",
    name: "CFA Franc BCEAO",
    code: "XOF",
  ),
  const CurrencyData(
    country: "TOKELAU",
    name: "New Zealand Dollar",
    code: "NZD",
  ),
  const CurrencyData(
    country: "TONGA",
    name: "Pa’anga",
    code: "TOP",
  ),
  const CurrencyData(
    country: "TRINIDAD AND TOBAGO",
    name: "Trinidad and Tobago Dollar",
    code: "TTD",
  ),
  const CurrencyData(
    country: "TUNISIA",
    name: "Tunisian Dinar",
    code: "TND",
  ),
  const CurrencyData(
    country: "TÜRKİYE",
    name: "Turkish Lira",
    code: "TRY",
  ),
  const CurrencyData(
    country: "TURKMENISTAN",
    name: "Turkmenistan New Manat",
    code: "TMT",
  ),
  const CurrencyData(
    country: "TURKS AND CAICOS ISLANDS (THE)",
    name: "US Dollar",
    code: "USD",
  ),
  const CurrencyData(
    country: "TUVALU",
    name: "Australian Dollar",
    code: "AUD",
  ),
  const CurrencyData(
    country: "UGANDA",
    name: "Uganda Shilling",
    code: "UGX",
  ),
  const CurrencyData(
    country: "UKRAINE",
    name: "Hryvnia",
    code: "UAH",
  ),
  const CurrencyData(
    country: "UNITED ARAB EMIRATES (THE)",
    name: "UAE Dirham",
    code: "AED",
  ),
  const CurrencyData(
    country: "UNITED KINGDOM OF GREAT BRITAIN AND NORTHERN IRELAND (THE)",
    name: "Pound Sterling",
    code: "GBP",
  ),
  const CurrencyData(
    country: "UNITED STATES MINOR OUTLYING ISLANDS (THE)",
    name: "US Dollar",
    code: "USD",
  ),
  const CurrencyData(
    country: "UNITED STATES OF AMERICA (THE)",
    name: "US Dollar",
    code: "USD",
  ),
  const CurrencyData(
    country: "UNITED STATES OF AMERICA (THE)",
    name: "US Dollar (Next day)",
    code: "USN",
  ),
  const CurrencyData(
    country: "URUGUAY",
    name: "Peso Uruguayo",
    code: "UYU",
  ),
  const CurrencyData(
    country: "URUGUAY",
    name: "Uruguay Peso en Unidades Indexadas (UI)",
    code: "UYI",
  ),
  const CurrencyData(
    country: "URUGUAY",
    name: "Unidad Previsional",
    code: "UYW",
  ),
  const CurrencyData(
    country: "UZBEKISTAN",
    name: "Uzbekistan Sum",
    code: "UZS",
  ),
  const CurrencyData(
    country: "VANUATU",
    name: "Vatu",
    code: "VUV",
  ),
  const CurrencyData(
    country: "VENEZUELA (BOLIVARIAN REPUBLIC OF)",
    name: "Bolívar Soberano",
    code: "VES",
  ),
  const CurrencyData(
    country: "VENEZUELA (BOLIVARIAN REPUBLIC OF)",
    name: "Bolívar Soberano",
    code: "VED",
  ),
  const CurrencyData(
    country: "VIET NAM",
    name: "Dong",
    code: "VND",
  ),
  const CurrencyData(
    country: "VIRGIN ISLANDS (BRITISH)",
    name: "US Dollar",
    code: "USD",
  ),
  const CurrencyData(
    country: "VIRGIN ISLANDS (U.S.)",
    name: "US Dollar",
    code: "USD",
  ),
  const CurrencyData(
    country: "WALLIS AND FUTUNA",
    name: "CFP Franc",
    code: "XPF",
  ),
  const CurrencyData(
    country: "WESTERN SAHARA",
    name: "Moroccan Dirham",
    code: "MAD",
  ),
  const CurrencyData(
    country: "YEMEN",
    name: "Yemeni Rial",
    code: "YER",
  ),
  const CurrencyData(
    country: "ZAMBIA",
    name: "Zambian Kwacha",
    code: "ZMW",
  ),
  const CurrencyData(
    country: "ZIMBABWE",
    name: "Zimbabwe Dollar",
    code: "ZWL",
  ),
];

final Map<String, String> _multinationCurrencyCountryNameOverride = {
  "USD": "US AND OTHERS",
  "EUR": "EUROPEAN UNION",
  "XCD": "CARIBBEAN ISLAND",
  "AUD": "AUSTRALIA AND OTHERS",
};

final Map<String, CurrencyData> iso4217CurrenciesGrouped =
    iso4217Currencies.groupBy((currencyData) => currencyData.code).map(
  (key, value) {
    return MapEntry(
      key,
      CurrencyData(
        code: value.first.code,
        country: _multinationCurrencyCountryNameOverride[value.first.code] ??
            value.map((e) => e.country).join(", "),
        name: value.first.name,
      ),
    );
  },
);

bool isCurrencyCodeValid(String currencyCode) {
  return iso4217CurrenciesGrouped.containsKey(currencyCode.toUpperCase());
}

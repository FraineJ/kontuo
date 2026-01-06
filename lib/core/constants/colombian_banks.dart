class ColombianBank {
  final String name;
  final String domain;
  final String logoUrl;

  const ColombianBank({
    required this.name,
    required this.domain,
    required this.logoUrl,
  });
}

class ColombianBanks {
  static const String _baseUrl = 'https://logo.bankconv.com';
  static const int _logoSize = 256;

  static String _getLogoUrl(String domain) {
    return '$_baseUrl/$domain?size=$_logoSize';
  }

  static const List<ColombianBank> banks = [
    ColombianBank(
      name: 'Bancolombia',
      domain: 'bancolombia.com',
      logoUrl: 'https://logo.bankconv.com/bancolombia.com?size=256',
    ),
    ColombianBank(
      name: 'Nequi',
      domain: 'nequi.com',
      logoUrl: 'https://logo.bankconv.com/nequi.com?size=256',
    ),
    ColombianBank(
      name: 'Banco de Bogotá',
      domain: 'bancodebogota.com',
      logoUrl: 'https://logo.bankconv.com/bancodebogota.com?size=256',
    ),
    ColombianBank(
      name: 'Banco de Occidente',
      domain: 'bancodeoccidente.com.co',
      logoUrl: 'https://logo.bankconv.com/bancodeoccidente.com.co?size=256',
    ),
    ColombianBank(
      name: 'Banco Popular',
      domain: 'bancopopular.com.co',
      logoUrl: 'https://logo.bankconv.com/bancopopular.com.co?size=256',
    ),
    ColombianBank(
      name: 'Banco AV Villas',
      domain: 'bancoavvillas.com.co',
      logoUrl: 'https://logo.bankconv.com/bancoavvillas.com.co?size=256',
    ),
    ColombianBank(
      name: 'Banco Caja Social',
      domain: 'bancocajasocial.com',
      logoUrl: 'https://logo.bankconv.com/bancocajasocial.com?size=256',
    ),
    ColombianBank(
      name: 'Banco Agrario',
      domain: 'bancoagrario.gov.co',
      logoUrl: 'https://logo.bankconv.com/bancoagrario.gov.co?size=256',
    ),
    ColombianBank(
      name: 'Banco Davivienda',
      domain: 'davivienda.com',
      logoUrl: 'https://logo.bankconv.com/davivienda.com?size=256',
    ),
    ColombianBank(
      name: 'Banco BBVA',
      domain: 'bbva.com.co',
      logoUrl: 'https://logo.bankconv.com/bbva.com.co?size=256',
    ),
    ColombianBank(
      name: 'Banco Santander',
      domain: 'santander.com.co',
      logoUrl: 'https://logo.bankconv.com/santander.com.co?size=256',
    ),
    ColombianBank(
      name: 'Banco Falabella',
      domain: 'bancofalabella.com.co',
      logoUrl: 'https://logo.bankconv.com/bancofalabella.com.co?size=256',
    ),
    ColombianBank(
      name: 'Banco Pichincha',
      domain: 'bancopichincha.com.co',
      logoUrl: 'https://logo.bankconv.com/bancopichincha.com.co?size=256',
    ),
    ColombianBank(
      name: 'Banco Colpatria',
      domain: 'colpatria.com',
      logoUrl: 'https://logo.bankconv.com/colpatria.com?size=256',
    ),
    ColombianBank(
      name: 'Banco Cooperativo Coopcentral',
      domain: 'coopcentral.coop',
      logoUrl: 'https://logo.bankconv.com/coopcentral.coop?size=256',
    ),
    ColombianBank(
      name: 'Bancoomeva',
      domain: 'bancoomeva.com.co',
      logoUrl: 'https://logo.bankconv.com/bancoomeva.com.co?size=256',
    ),
    ColombianBank(
      name: 'Banco W',
      domain: 'bancow.com.co',
      logoUrl: 'https://logo.bankconv.com/bancow.com.co?size=256',
    ),
    ColombianBank(
      name: 'Banco Serfinanza',
      domain: 'bancoserfinanza.com',
      logoUrl: 'https://logo.bankconv.com/bancoserfinanza.com?size=256',
    ),
    ColombianBank(
      name: 'Banco Agrario de Colombia',
      domain: 'bancoagrario.gov.co',
      logoUrl: 'https://logo.bankconv.com/bancoagrario.gov.co?size=256',
    ),
    ColombianBank(
      name: 'Banco de la República',
      domain: 'banrep.gov.co',
      logoUrl: 'https://logo.bankconv.com/banrep.gov.co?size=256',
    ),
  ];

  /// Obtiene el banco por su nombre
  static ColombianBank? getBankByName(String name) {
    try {
      return banks.firstWhere(
        (bank) => bank.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtiene el logo URL por el nombre del banco
  static String? getLogoUrlByName(String bankName) {
    final bank = getBankByName(bankName);
    return bank?.logoUrl;
  }

  /// Obtiene el logo URL por el dominio del banco
  static String getLogoUrlByDomain(String domain) {
    return _getLogoUrl(domain);
  }

  /// Lista de nombres de bancos
  static List<String> get bankNames {
    return banks.map((bank) => bank.name).toList();
  }
}


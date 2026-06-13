import 'package:flutter_test/flutter_test.dart';
import 'package:depometrik/core/ocr/receipt_ocr_service.dart';

void main() {
  group('ReceiptOcrService - Yerel Ayrıştırma Testleri', () {
    final ocrService = ReceiptOcrService();

    test('İlk örnek fiş metnini başarıyla ayrıştırmalıdır', () {
      const rawText = """
KAYAN PETROL ÜRÜNLERİ
YAKIT İNŞ.GIDA.NK.SN.LTD.ŞTİ.
HAVZA VD.NO:5370533075
ÜNVRSİTE M.SAMSUN K.YOL 5KM N165
TEL:0533-672-9713 HAVZA/SAMSUN

TARİH:14/07/2016 FİŞ NO: 0092
SAAT :14:35

16 JCT 66

44,780LT X 3,350B
MOTORİN %18 *150,01

KDV *22,88
TOP *150,01

NAKİT *150,01

EKÜ NO:0014   Z NO:0121
   BBM 00000873
""";

      final data = ocrService.extractData(rawText);

      expect(data.liters, equals(44.78));
      expect(data.unitPrice, equals(3.35));
      expect(data.totalPrice, equals(150.01));
      expect(data.purchaseDate, equals(DateTime(2016, 7, 14)));
      expect(data.fuelType, equals('MAZOT'));
    });

    test('İkinci örnek (Şimşekli Petrol) fiş metnini başarıyla ayrıştırmalıdır', () {
      const rawText = """
ŞİMŞEKLİ PETROL DŞ.TİC.PAZ.A.Ş
SİLİFKE VD.8130533075
SİLİFKE TİC.SİCİL NO:3328
SARICALAR MAH.A.TÜRKEŞ BV.N304
SİLİFKE/MERSİN
TLF:0324 7142221 0 324 7141130
TEŞEKKÜR EDERİZ

02-10-2018         SAAT: 10:41
FİŞ NO:60

       33 KKA 12

14.380 LT X 6.950
K BENZİN 95 %18       *100.00

KDV                   *15.25
TOP                  *100.00

KREDİ                *100.00

POMPA: 002
İSTASYON

EKÜ NO: 0004   Z NO: 0580
       MF AD 10100035
""";

      final data = ocrService.extractData(rawText);

      expect(data.liters, equals(14.38));
      expect(data.unitPrice, equals(6.95));
      expect(data.totalPrice, equals(100.0));
      expect(data.purchaseDate, equals(DateTime(2018, 10, 2)));
      expect(data.fuelType, equals('BENZİN'));
    });

    test('Üçüncü örnek (Opet) fiş metnini başarıyla ayrıştırmalıdır', () {
      const rawText = """
KERVAN AKARYAKIT DOGALGAZ
NAK.GIDA SAN.VE TIC.LTD.STI.
CUMHURIYET MH.ISIBANK SOK.N:35
DUZCE V.D:545 061 2881
MERSIS NO:0-545-0612-88100011
TIC.SIC.NO:7355
TEL:514 1188 FAX:5236767 DUZCE

15-01-2017         SAAT: 20:47
FIS NO :167

       81 DF 405

41.230 LT X 4.730
MOTORIN %18           *195.02

KDV                   *29.75
TOP                  *195.02

K. KART               *195.02

POMPA: 002
ISTASYON
       MF AJ 70800176
       opet
""";

      final data = ocrService.extractData(rawText);

      expect(data.liters, equals(41.23));
      expect(data.unitPrice, equals(4.73));
      expect(data.totalPrice, equals(195.02));
      expect(data.purchaseDate, equals(DateTime(2017, 1, 15)));
      expect(data.fuelType, equals('MAZOT'));
      expect(data.stationBrand, equals('OPET'));
    });

    test('Dördüncü örnek (İrfanlı Petrol - Son Log) fiş metnini başarıyla ayrıştırmalıdır', () {
      const rawText = """
itişi Gobgle'da Ara S hr. hrfar- petnlenzin-ov +   
filas.sıkavelvaı.corn'onnth!:|3 FutLrnh trl lhe nz o|1.lpg
-IRFANL! PE TRUL A.5. OIT BATI)
'ERIRLI MH. CEBIRL I KUME FVI FRI
ARA
NJ: 127:B OHT-5 E VREN\ANK
GUNE ȘLI VD: 4631 179165
TIC. SIC. NO:276850-5
MERSİS: 0463117916500001
IARIH: 28, 07.2023 SAAT: 09:32
FIS NO: 60      
O6 BD 6963G     
50,630 LT X 36,550
KURSUNSUZ 95 %20 1.850, 53
KDV
:308, 42        
TOPLAM
*1.850, 53      
K.KART
*1.850, 53      
POMPA NO: 004   
ISTASYON        
EKU NO: 0003    
2 NO: 0738      
ME DI 13050014  
Q Arg
""";

      final data = ocrService.extractData(rawText);

      expect(data.liters, equals(50.63));
      expect(data.unitPrice, equals(36.55));
      expect(data.totalPrice, equals(1850.53));
      expect(data.purchaseDate, equals(DateTime(2023, 7, 28)));
      expect(data.fuelType, equals('BENZİN'));
    });
  });
}

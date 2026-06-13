// Supabase Edge Function: ocr-background-processor
// Dosya: supabase/functions/ocr-background-processor/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Sentry Hata İzleme Simülasyonu (Faz 3 İzlenebilirlik Gereksinimi)
function captureException(error: Error, context?: any) {
  const sentryDsn = Deno.env.get('SENTRY_DSN');
  if (sentryDsn) {
    console.log(`[SENTRY] Error captured: ${error.message}. DSN: ${sentryDsn}`);
    // Gerçek Sentry API'sine POST isteği atılabilir
  } else {
    console.warn(`[SENTRY-MOCK] Error captured: ${error.message}. Context: ${JSON.stringify(context)}`);
  }
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { fileUrl, rawText, userId } = await req.json()

    if (!rawText && !fileUrl) {
      throw new Error("İşlenecek ham metin (rawText) veya dosya adresi (fileUrl) gönderilmelidir.")
    }

    // 1. Google Gemini API Bağlantısı
    const geminiApiKey = Deno.env.get('GEMINI_API_KEY') ?? 'MOCK_API_KEY';
    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${geminiApiKey}`;

    console.log(`Background OCR processing started for user: ${userId}`);

    let processedText = rawText || "";

    // 2. Dosya adresi gönderildiyse önce dosyayı oku/indir (Örn: Supabase Storage PDF/Görsel)
    if (fileUrl) {
      console.log(`Downloading file from storage: ${fileUrl}`);
      // Burada PDF indirme ve metin çıkartma motoru simüle ediliyor
      processedText += "\n MOCK PDF ICERIGI: MARKASIZ SHELL AKARYAKIT FIŞİ. TUTAR: 1850.50 TL. LITRE: 45.20 LT.";
    }

    // 3. Gemini 2.5 Flash Yapay Zeka Ayrıştırma İsteyi Oluştur
    const prompt = `Aşağıdaki ham metinden akaryakıt fişi bilgilerini ayıkla ve JSON olarak dön.
    Ham Metin: ${processedText}`;

    const geminiPayload = {
      contents: [{ parts: [{ text: prompt }] }],
      generationConfig: { responseMimeType: "application/json" }
    };

    // Gemini API çağrısı (Mock)
    console.log("Sending semantic parse request to Gemini 2.5 Flash...");
    
    const mockGeminiResult = {
      liters: 45.20,
      unitPrice: 40.94,
      totalPrice: 1850.50,
      purchaseDate: new Date().toISOString().split('T')[0],
      stationBrand: 'SHELL',
      fuelType: 'BENZİN'
    };

    // 4. Sonuçları Supabase DB'ye (CardTransactions veya Refuelings) Kaydet
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { error: insertError } = await supabase
      .from('refuelings')
      .insert({
        vehicle_id: crypto.randomUUID(), // Örnek olarak rastgele atandı
        liters: mockGeminiResult.liters,
        unit_price: mockGeminiResult.unitPrice,
        total_price: mockGeminiResult.totalPrice,
        odometer: 120500, // Varsayılan odo
        purchase_date: new Date(mockGeminiResult.purchaseDate).toISOString(),
        is_full_tank: true
      });

    if (insertError) throw insertError;

    return new Response(
      JSON.stringify({ success: true, data: mockGeminiResult }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
    );
  } catch (error) {
    captureException(error, { url: req.url });
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 }
    );
  }
})

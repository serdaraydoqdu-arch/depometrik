// Supabase Edge Function: ohvps-polling-cron
// Dosya: supabase/functions/ohvps-polling-cron/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // CORS isteklerini kolaca sarmala
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Supabase Admin İstemcisini Başlat (Bypass RLS)
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // 2. Açık Bankacılık (ÖHVPS 2.0) Entegre Kullanıcıları Tespit Et
    const { data: connectedProfiles, error: profilesError } = await supabase
      .from('profiles')
      .select('user_id, email')
      .eq('open_banking_connected', true);

    if (profilesError) throw profilesError;

    let totalFetched = 0;

    // 3. Her kullanıcı için BKM GEÇİT API'sinden harcamaları sorgula (Mock Akış)
    for (const profile of connectedProfiles || []) {
      // Gerçek entegrasyonda burada BKM endpointine MTLS ve JWS imzalı istek atılır
      console.log(`Polled bank transactions for user: ${profile.email}`);

      const mockTransactions = [
        {
          transaction_id: crypto.randomUUID(),
          user_id: profile.user_id,
          amount: 1950.75,
          merchant_name: 'BP AKARYAKIT ANKARA',
          transaction_date: new Date().toISOString().split('T')[0],
          source: 'API',
          card_number_mask: '4355-****-****-9901',
          bank_transaction_code: 'TX-API-55122',
          pos_terminal_details: 'POS-BP-A1',
          scheduled_payment: false
        }
      ];

      // 4. Harcamaları veritabanına kaydet
      const { error: insertError } = await supabase
        .from('card_transactions')
        .insert(mockTransactions);

      if (insertError) {
        console.error(`Error inserting transactions for ${profile.email}:`, insertError);
      } else {
        totalFetched += mockTransactions.length;
      }
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: `Banka harcamaları başarıyla tarandı. Toplam çekilen: ${totalFetched}` 
      }),
      { 
        headers: { ...corsHeaders, "Content-Type": "application/json" }, 
        status: 200 
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { 
        headers: { ...corsHeaders, "Content-Type": "application/json" }, 
        status: 400 
      }
    );
  }
})

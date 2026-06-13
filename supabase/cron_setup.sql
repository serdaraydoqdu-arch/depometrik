-- Supabase pg_cron ve pg_net ile Zamanlanmış Görevlerin Yapılandırılması
-- Dosya: supabase/cron_setup.sql

-- 1. Gerekli eklentilerin PostgreSQL'e kurulması
CREATE EXTENSION IF NOT EXISTS pg_net;
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- 2. Banka hareketlerini her sabah saat 08:00'de çeken Cron Görevinin Oluşturulması
-- Bu tetikleyici, Supabase Deno Edge Fonksiyonumuza HTTP POST isteği gönderir.
SELECT cron.schedule(
    'ohvps-bank-polling-job',  -- Cron görev adı
    '0 8 * * *',               -- Her sabah 08:00 UTC planı
    $$
    SELECT net.http_post(
        url := 'https://napqcopzozmipkuzmdee.functions.supabase.co/ohvps-polling-cron',
        headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'Authorization', 'Bearer MOCK_SUPERUSER_SERVICE_ROLE_KEY' -- Supabase Vault ile şifrelenecek servis anahtarı
        ),
        body := jsonb_build_object(
            'trigger', 'cron',
            'action', 'fetch_bank_statements'
        )
    );
    $$
);

-- 3. Süresi dolmuş çevrimdışı işlem kuyruklarının otomatik temizlenmesi (Ayda bir kez çalışır)
SELECT cron.schedule(
    'clean-old-offline-queues',
    '0 0 1 * *', -- Her ayın 1'inde gece yarısı
    $$
    DELETE FROM public.destructive_offline_queue 
    WHERE created_at < now() - INTERVAL '30 days';
    $$
);

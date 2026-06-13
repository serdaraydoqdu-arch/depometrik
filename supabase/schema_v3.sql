-- DepoMetrik Faz 3 Supabase Veritabanı Şema Güncellemeleri
-- Dosya: supabase/schema_v3.sql

-- 1. Profiles Tablosu Güncellemeleri
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS open_banking_connected BOOLEAN DEFAULT false NOT NULL,
ADD COLUMN IF NOT EXISTS subscription_status TEXT;

-- 2. Card Transactions Tablosu Güncellemeleri
ALTER TABLE public.card_transactions
ADD COLUMN IF NOT EXISTS card_number_mask VARCHAR(30),
ADD COLUMN IF NOT EXISTS bank_transaction_code VARCHAR(100),
ADD COLUMN IF NOT EXISTS pos_terminal_details TEXT,
ADD COLUMN IF NOT EXISTS scheduled_payment BOOLEAN DEFAULT false NOT NULL;

-- 3. Destructive Offline Queue Tablosu (Yıkıcı işlemlerin denetimi için)
CREATE TABLE IF NOT EXISTS public.destructive_offline_queue (
    queue_id VARCHAR(100) PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.profiles(user_id) ON DELETE CASCADE,
    entity_name VARCHAR(100) NOT NULL,
    entity_id VARCHAR(100) NOT NULL,
    action_type VARCHAR(50) NOT NULL, -- DELETE, UPDATE_CRITICAL
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. Attachment Queue Tablosu (Çevrimdışı fiş/belgelerin yükleme takibi)
CREATE TABLE IF NOT EXISTS public.attachment_queue (
    attachment_id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.profiles(user_id) ON DELETE CASCADE,
    file_path TEXT NOT NULL,
    remote_storage_path TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'PENDING' NOT NULL CHECK (status IN ('PENDING', 'UPLOADING', 'SUCCESS', 'FAILED')),
    retry_count INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- RLS (Row-Level Security) Aktifleştirilmesi
ALTER TABLE public.destructive_offline_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attachment_queue ENABLE ROW LEVEL SECURITY;

-- RLS Politikalarının Yazılması (Veri izolasyonu)
CREATE POLICY "Kullanıcılar kendi yıkıcı işlem kuyruğunu görebilir ve düzenleyebilir" 
ON public.destructive_offline_queue FOR ALL 
USING (auth.uid() = user_id);

CREATE POLICY "Kullanıcılar kendi belge yükleme kuyruğunu görebilir ve düzenleyebilir" 
ON public.attachment_queue FOR ALL 
USING (auth.uid() = user_id);

-- PowerSync Replikasyon Rolü (BypassRLS) ve Tetikleyicilerin İzinleri
-- PowerSync sunucusunun Postgres WAL'larını okuyabilmesi için replikasyon yayınına eklenmelidir.
-- Örnek: ALTER PUBLICATION powersync_publication ADD TABLE public.destructive_offline_queue, public.attachment_queue;

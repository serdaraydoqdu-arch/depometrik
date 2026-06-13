-- DepoMetrik Supabase Veritabanı Şeması ve RLS Politikaları
-- Oluşturulma Tarihi: 2026-06-01

-- 0. PostGIS Eklentisi (Coğrafi Sorgular ve Mesafe Hesaplamaları İçin)
CREATE EXTENSION IF NOT EXISTS postgis;

-- 1. PROFILES TABLOSU (Supabase Auth ile entegre)
CREATE TABLE IF NOT EXISTS public.profiles (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    premium_status BOOLEAN DEFAULT false NOT NULL,
    full_name TEXT,
    tckn TEXT,
    phone_number TEXT
);

-- 2. VEHICLES TABLOSU (Kullanıcı Araçları)
CREATE TABLE IF NOT EXISTS public.vehicles (
    vehicle_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(user_id) ON DELETE CASCADE,
    plate VARCHAR(15) NOT NULL,
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    fuel_type TEXT CHECK (fuel_type IN ('BENZIN', 'DIZEL', 'LPG', 'ELEKTRIK')) NOT NULL,
    initial_odometer INTEGER NOT NULL CHECK (initial_odometer >= 0),
    current_odometer INTEGER NOT NULL CHECK (current_odometer >= 0),
    CONSTRAINT current_greater_or_equal CHECK (current_odometer >= initial_odometer)
);

-- 3. STATIONS TABLOSU (Akaryakıt İstasyonları Coğrafi Veritabanı)
CREATE TABLE IF NOT EXISTS public.stations (
    station_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_name VARCHAR(100) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    geom GEOMETRY(Point, 4326) NOT NULL,
    city VARCHAR(50) NOT NULL,
    district VARCHAR(50) NOT NULL
);

-- 4. REFUELINGS TABLOSU (Yakıt Alım Kayıtları)
CREATE TABLE IF NOT EXISTS public.refuelings (
    refueling_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL REFERENCES public.vehicles(vehicle_id) ON DELETE CASCADE,
    station_id UUID REFERENCES public.stations(station_id) ON DELETE SET NULL,
    liters DOUBLE PRECISION NOT NULL CHECK (liters > 0),
    unit_price DOUBLE PRECISION NOT NULL CHECK (unit_price > 0),
    total_price DOUBLE PRECISION NOT NULL CHECK (total_price > 0),
    odometer INTEGER NOT NULL CHECK (odometer >= 0),
    purchase_date TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    is_full_tank BOOLEAN DEFAULT true NOT NULL
);

-- 5. CARD_TRANSACTIONS TABLOSU (SMS/PDF Akaryakıt Harcamaları)
CREATE TABLE IF NOT EXISTS public.card_transactions (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(user_id) ON DELETE CASCADE,
    refueling_id UUID REFERENCES public.refuelings(refueling_id) ON DELETE SET NULL,
    transaction_date DATE NOT NULL,
    amount DOUBLE PRECISION NOT NULL CHECK (amount > 0),
    merchant_name VARCHAR(150) NOT NULL,
    source TEXT CHECK (source IN ('PDF', 'SMS', 'API')) NOT NULL
);

-- 6. CAMPAIGNS TABLOSU (Banka Akaryakıt Kampanyaları)
CREATE TABLE IF NOT EXISTS public.campaigns (
    campaign_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(user_id) ON DELETE CASCADE,
    bank_name VARCHAR(100) NOT NULL,
    station_brand VARCHAR(100) NOT NULL,
    target_tx_count INTEGER NOT NULL CHECK (target_tx_count > 0),
    current_tx_count INTEGER DEFAULT 0 NOT NULL CHECK (current_tx_count >= 0),
    reward_amount DOUBLE PRECISION NOT NULL CHECK (reward_amount > 0),
    expiry_date TIMESTAMP WITH TIME ZONE NOT NULL
);

-- 7. OBD_READINGS TABLOSU (OBD-II Dongle Ham Veri Akışı)
CREATE TABLE IF NOT EXISTS public.obd_readings (
    reading_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL REFERENCES public.vehicles(vehicle_id) ON DELETE CASCADE,
    odometer_value INTEGER NOT NULL CHECK (odometer_value >= 0),
    fuel_level_ratio DOUBLE PRECISION NOT NULL CHECK (fuel_level_ratio >= 0.0 AND fuel_level_ratio <= 1.0),
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- INDEX Tanımlamaları (Sorgu Performansı İçin)
CREATE INDEX IF NOT EXISTS idx_vehicles_user_id ON public.vehicles(user_id);
CREATE INDEX IF NOT EXISTS idx_refuelings_vehicle_id ON public.refuelings(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_card_transactions_user_id ON public.card_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_campaigns_user_id ON public.campaigns(user_id);
CREATE INDEX IF NOT EXISTS idx_obd_readings_vehicle_id ON public.obd_readings(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_stations_geom ON public.stations USING gist(geom);

-- TRIGGER 1: Araç Güncel Kilometresini Tüketim Girişiyle Güncelleme
CREATE OR REPLACE FUNCTION public.update_vehicle_odometer()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.vehicles
    SET current_odometer = GREATEST(current_odometer, NEW.odometer)
    WHERE vehicle_id = NEW.vehicle_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER trigger_update_vehicle_odometer
AFTER INSERT OR UPDATE ON public.refuelings
FOR EACH ROW
EXECUTE FUNCTION public.update_vehicle_odometer();

-- TRIGGER 2: Yeni Kullanıcı Kaydolduğunda Otomatik Profil Oluşturma
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (user_id, email, premium_status, full_name, phone_number, tckn)
    VALUES (
        NEW.id, 
        NEW.email, 
        false,
        (NEW.raw_user_meta_data->>'full_name'),
        (NEW.raw_user_meta_data->>'phone_number'),
        (NEW.raw_user_meta_data->>'tckn')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user();

-- ROW-LEVEL SECURITY (RLS) AKTİFLEŞTİRİLMESİ
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.refuelings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.obd_readings ENABLE ROW LEVEL SECURITY;

-- RLS POLİTİKALARI (Kullanıcı Veri İzolasyonu)

-- Profiles
CREATE POLICY "Kullanıcılar kendi profillerini görebilir ve düzenleyebilir" 
ON public.profiles FOR ALL 
USING (auth.uid() = user_id);

-- Vehicles
CREATE POLICY "Kullanıcılar kendi araçlarını görebilir ve düzenleyebilir" 
ON public.vehicles FOR ALL 
USING (auth.uid() = user_id);

-- Stations (İstasyonlar tüm kullanıcılara salt okunurdur)
CREATE POLICY "İstasyonlar herkes tarafından okunabilir" 
ON public.stations FOR SELECT 
USING (true);

-- Refuelings (Aracın sahibine göre erişim kısıtlanır)
CREATE POLICY "Kullanıcılar kendi araçlarının yakıt alımlarını görebilir ve düzenleyebilir" 
ON public.refuelings FOR ALL 
USING (
    EXISTS (
        SELECT 1 FROM public.vehicles 
        WHERE public.vehicles.vehicle_id = public.refuelings.vehicle_id 
        AND public.vehicles.user_id = auth.uid()
    )
);

-- Card Transactions
CREATE POLICY "Kullanıcılar kendi kart işlemlerini görebilir ve düzenleyebilir" 
ON public.card_transactions FOR ALL 
USING (auth.uid() = user_id);

-- Campaigns
CREATE POLICY "Kullanıcılar kendi kampanyalarını görebilir ve düzenleyebilir" 
ON public.campaigns FOR ALL 
USING (auth.uid() = user_id);

-- OBD Readings
CREATE POLICY "Kullanıcılar kendi araçlarının OBD verilerini görebilir ve düzenleyebilir" 
ON public.obd_readings FOR ALL 
USING (
    EXISTS (
        SELECT 1 FROM public.vehicles 
        WHERE public.vehicles.vehicle_id = public.obd_readings.vehicle_id 
        AND public.vehicles.user_id = auth.uid()
    )
);

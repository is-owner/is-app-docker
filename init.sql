-- このファイルは、PostgreSQLの初期化スクリプトとして使用されます。
-- initdb/init.sql

-- ユーザーが存在しない場合のみ作成
DO
$$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE rolname = 'is-career-app-db-user') THEN
      CREATE ROLE "is-career-app-db-user" WITH LOGIN PASSWORD 'is2025';
   END IF;
END
$$;

-- データベースが存在しない場合のみ作成
DO
$$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_database
      WHERE datname = 'is-career-app-db') THEN
      CREATE DATABASE "is-career-app-db" OWNER "is-career-app-db-user";
   END IF;
END
$$;

-- users テーブルが存在しない場合のみ作成
CREATE TABLE IF NOT EXISTS Users (
  user_id SERIAL PRIMARY KEY,
  user_type VARCHAR(20) NOT NULL,                         -- ユーザー種別 (AGENT, COMPANY, JOBSEEKER, ADMIN)
  email VARCHAR(100) UNIQUE NOT NULL,                     -- メールアドレス
  password_hash VARCHAR(255) NOT NULL,                    -- パスワード
  full_name VARCHAR(100) NOT NULL,                        -- 氏名
  full_name_kana VARCHAR(100),                            -- 氏名（カナ）
  company_id INT,                                         -- 企業ID（外部キー）
  last_login_at TIMESTAMP,                                -- 最終ログイン日時
  is_locked BOOLEAN DEFAULT FALSE,                        -- アカウントロックフラグ
  email_verified BOOLEAN DEFAULT FALSE,                   -- メール認証フラグ
  is_active BOOLEAN DEFAULT TRUE,                         -- 有効フラグ
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,         -- 登録日時
  created_by INT,                                         -- 登録者ID
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,         -- 更新日時
  updated_by INT,                                         -- 更新者ID
  is_deleted BOOLEAN DEFAULT FALSE                        -- 削除フラグ
);

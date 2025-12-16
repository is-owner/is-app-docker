-- このファイルは、PostgreSQLの初期化スクリプトとして使用されます。
-- initdb/init.sql

--------------------------------------------
-- 1. ロール（ユーザー）とデータベースの作成
--------------------------------------------

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

-- 以下、データベース接続後、テーブル作成とデータ挿入を行うことを想定
-- （Docker環境によっては、このDDL/DML部分を別のファイルに分け、DB作成後に実行する必要があります）

--------------------------------------------
-- 2. テーブル定義 (DDL)
-- 外部キーの依存関係を考慮し、依存元から順に作成
--------------------------------------------

-- M_JOB_TYPE (職種タイプマスター)
CREATE TABLE IF NOT EXISTS M_JOB_TYPE (
    job_type_id INT PRIMARY KEY,
    job_code VARCHAR(10),
    job_name VARCHAR(50),
    job_name_kana VARCHAR(100),
    description VARCHAR(200),
    display_order INT,
    active BOOLEAN
);

-- M_INDUSTRY_TYPE (業種タイプマスター)
CREATE TABLE IF NOT EXISTS M_INDUSTRY_TYPE (
    industry_type_id INT PRIMARY KEY,
    industry_name_kana VARCHAR(100),
    industry_code VARCHAR(10),
    industry_name VARCHAR(50),
    description VARCHAR(200),
    display_order INT,
    active BOOLEAN
);

-- M_SELECTION_STATUS (選考ステータスマスター)
CREATE TABLE IF NOT EXISTS M_SELECTION_STATUS (
    status_id INT PRIMARY KEY,
    status_type VARCHAR(20),
    status_code VARCHAR(30),
    status_name VARCHAR(50),
    status_name_kana VARCHAR(100),
    description VARCHAR(200),
    phase INT,
    next_step_available BOOLEAN,
    agent_person_success BOOLEAN,
    is_done BOOLEAN,
    action_required BOOLEAN,
    background_color VARCHAR(7),
    text_color VARCHAR(7),
    icon VARCHAR(50),
    active BOOLEAN,
    is_customizable BOOLEAN,
    is_system_defined BOOLEAN,
    created_at TIMESTAMP,
    created_by INT,
    updated_at TIMESTAMP,
    updated_by INT,
    is_deleted BOOLEAN
);

-- C_COMPANY (会社テーブル)
CREATE TABLE IF NOT EXISTS C_COMPANY (
    company_id INT PRIMARY KEY,
    company_name VARCHAR(100),
    company_name_kana VARCHAR(100),
    industry_type_id INT,
    postal_code VARCHAR(9),
    prefecture VARCHAR(20),
    city VARCHAR(50),
    address VARCHAR(200),
    phone_number VARCHAR(20),
    employee_count INT,
    business_description TEXT,
    document_assignments INT,
    company_description TEXT,
    recruitment_manager_name VARCHAR(50),
    recruitment_email VARCHAR(100),
    is_active BOOLEAN,
    created_at TIMESTAMP,
    created_by INT,
    updated_at TIMESTAMP,
    updated_by INT,
    is_deleted BOOLEAN,
    FOREIGN KEY (industry_type_id) REFERENCES M_INDUSTRY_TYPE(industry_type_id)
);

-- C_USER (ユーザーテーブル)
CREATE TABLE IF NOT EXISTS C_USER (
    user_id INT PRIMARY KEY,
    user_type VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    full_name_kana VARCHAR(100),
    company_id INT,
    last_login_at TIMESTAMP,
    is_locked BOOLEAN DEFAULT FALSE,
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by INT,
    is_deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (company_id) REFERENCES C_COMPANY(company_id)
);

-- C_AGENT_PERSON (エージェント担当者テーブル)
CREATE TABLE IF NOT EXISTS C_AGENT_PERSON (
    agent_person_id INT PRIMARY KEY,
    user_id INT UNIQUE,
    job_type_id INT,
    phone_number VARCHAR(20),
    department VARCHAR(50),
    specialization VARCHAR(200),
    email VARCHAR(100),
    is_active BOOLEAN,
    created_at TIMESTAMP,
    created_by INT,
    updated_at TIMESTAMP,
    updated_by INT,
    is_deleted BOOLEAN,
    FOREIGN KEY (user_id) REFERENCES C_USER(user_id),
    FOREIGN KEY (job_type_id) REFERENCES M_JOB_TYPE(job_type_id)
);

-- C_JOB_APPLICATION_INFO (求職者情報テーブル)
CREATE TABLE IF NOT EXISTS C_JOB_APPLICATION_INFO (
    job_applicant_id INT PRIMARY KEY,
    selection_status_id INT,
    mediator VARCHAR,
    name VARCHAR,
    name_kana VARCHAR,
    gender VARCHAR,
    date_of_birth DATE,
    nationality VARCHAR,
    mail_address VARCHAR,
    telephone_number VARCHAR,
    postal_code VARCHAR,
    prefecture_id INT,
    address VARCHAR,
    final_academic_background VARCHAR,
    work_history VARCHAR,
    resume VARCHAR,
    others1 TEXT,
    status VARCHAR,
    first_interview_date DATE,
    number_of_experienced_companies INT,
    career_affiliation_name VARCHAR,
    career_industry VARCHAR,
    career_occupation VARCHAR,
    career_post VARCHAR,
    career_joining_date DATE,
    career_retirement_date DATE,
    reason_for_changing_job TEXT,
    most_recent_annual_income INT,
    desired_annual_income INT,
    desired_work_location VARCHAR,
    desired_industry VARCHAR,
    desired_occupation VARCHAR,
    english_proficiency VARCHAR,
    skill VARCHAR,
    qualifications_held VARCHAR,
    recommendation TEXT,
    free_entry_field TEXT,
    created_user VARCHAR,
    created_at DATE,
    updated_user VARCHAR,
    updated_at DATE,
    FOREIGN KEY (selection_status_id) REFERENCES M_SELECTION_STATUS(status_id)
);

-- C_RECRUITMENT_CONSIDERATION_LIST (採用検討リストテーブル)
CREATE TABLE IF NOT EXISTS C_RECRUITMENT_CONSIDERATION_LIST (
    job_applicant_id INT PRIMARY KEY,
    work_place VARCHAR,
    commission INT,
    assumed_gender VARCHAR,
    estimated_annual_income INT,
    employment_type VARCHAR,
    estimated_age INT,
    job_description VARCHAR,
    required_condition VARCHAR,
    created_user VARCHAR,
    created_at DATE,
    updated_user VARCHAR,
    updated_at DATE,
    FOREIGN KEY (job_applicant_id) REFERENCES C_JOB_APPLICATION_INFO(job_applicant_id)
);

-- K_JOB_POSTING_INFO (求人情報テーブル)
CREATE TABLE IF NOT EXISTS K_JOB_POSTING_INFO (
    posting_id INT PRIMARY KEY,
    company_id INT,
    industry_type_id INT,
    job_type_id INT,
    job_title VARCHAR(255),
    work_location VARCHAR(255),
    salary_min INT,
    salary_max INT,
    employment_type VARCHAR(100),
    recruiter_name VARCHAR(100),
    posting_start_date DATE,
    posting_end_date DATE,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES C_COMPANY(company_id),
    FOREIGN KEY (industry_type_id) REFERENCES M_INDUSTRY_TYPE(industry_type_id),
    FOREIGN KEY (job_type_id) REFERENCES M_JOB_TYPE(job_type_id)
);

-- K_JOB_POSTING_INFO_DETAIL (求人情報詳細テーブル)
CREATE TABLE IF NOT EXISTS K_JOB_POSTING_INFO_DETAIL (
    job_requirement_id INT PRIMARY KEY,
    posting_id INT UNIQUE,
    job_title VARCHAR(100),
    work_location VARCHAR(255),
    work_address VARCHAR(500),
    has_relocation BOOLEAN,
    business_content TEXT,
    probation_period VARCHAR(100),
    probation_notes TEXT,
    break_time VARCHAR(100),
    employment_type VARCHAR(100),
    working_hours VARCHAR(255),
    overtime_work VARCHAR(255),
    compensation_benefits TEXT,
    welfare_benefits TEXT,
    holidays_vacation VARCHAR(255),
    holiday_notes TEXT,
    required_skills TEXT,
    preferred_skills TEXT,
    preferred_skills_other TEXT,
    other_requirements TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (posting_id) REFERENCES K_JOB_POSTING_INFO(posting_id)
);

-- K_JOB_POSTING_FEE (求人仲介手数料テーブル)
CREATE TABLE IF NOT EXISTS K_JOB_POSTING_FEE (
    job_posting_fee_id INT PRIMARY KEY,
    job_posting_id INT,
    fee_value DECIMAL(10, 2),
    type VARCHAR(30),
    payment_timing VARCHAR(100),
    fee_transfer_date TIMESTAMP,
    note TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (job_posting_id) REFERENCES K_JOB_POSTING_INFO(posting_id)
);

-- K_APPLICATION_LIST (応募一覧テーブル)
CREATE TABLE IF NOT EXISTS K_APPLICATION_LIST (
    application_id INT PRIMARY KEY,
    job_posting_id INT,
    job_applicant_id INT,
    agent_person_id INT,
    selection_status_id INT,
    applied_at TIMESTAMP,
    recommendation_comment TEXT,
    status_updated_at TIMESTAMP,
    is_active BOOLEAN,
    created_at TIMESTAMP,
    created_by INT,
    updated_at TIMESTAMP,
    updated_by INT,
    is_deleted BOOLEAN,
    FOREIGN KEY (job_posting_id) REFERENCES K_JOB_POSTING_INFO(posting_id),
    FOREIGN KEY (job_applicant_id) REFERENCES C_JOB_APPLICATION_INFO(job_applicant_id),
    FOREIGN KEY (agent_person_id) REFERENCES C_AGENT_PERSON(agent_person_id),
    FOREIGN KEY (selection_status_id) REFERENCES M_SELECTION_STATUS(status_id)
);

-- K_APPLICATION_DETAIL (応募詳細テーブル)
CREATE TABLE IF NOT EXISTS K_APPLICATION_DETAIL (
    application_detail_id INT PRIMARY KEY,
    application_id INT UNIQUE,
    motivation TEXT,
    preferred_interview_datetime1 TIMESTAMP,
    preferred_interview_datetime2 TIMESTAMP,
    preferred_interview_datetime3 TIMESTAMP,
    preferred_interview_location VARCHAR(100),
    preferred_interview_format VARCHAR(20),
    withdrawal_datetime TIMESTAMP,
    withdrawal_reason TEXT,
    document_screening_passed_date DATE,
    first_interview_passed_date DATE,
    second_interview_passed_date DATE,
    final_interview_passed_date DATE,
    offer_notification_date DATE,
    offer_response_deadline DATE,
    offer_response_date DATE,
    offer_response_result VARCHAR(20),
    offered_annual_salary INT,
    offer_conditions_detail TEXT,
    expected_joining_date DATE,
    salary_negotiation_comment TEXT,
    other_remarks TEXT,
    company_rating SMALLINT, -- TINYINTはSMALLINTに修正済み
    self_pr TEXT,
    career_summary_file VARCHAR(255),
    created_at TIMESTAMP,
    created_by INT,
    updated_at TIMESTAMP,
    updated_by INT,
    is_deleted BOOLEAN,
    FOREIGN KEY (application_id) REFERENCES K_APPLICATION_LIST(application_id)
);

--------------------------------------------
-- 3. ダミーデータの挿入 (DML)
--------------------------------------------

-- M_JOB_TYPE
INSERT INTO M_JOB_TYPE (job_type_id, job_code, job_name, job_name_kana, description, display_order, active) VALUES
(1, 'ENG', 'エンジニア', 'エンジニア', '開発職全般', 10, TRUE),
(2, 'SAL', '営業', 'エイギョウ', '法人・個人営業', 20, TRUE);

-- M_INDUSTRY_TYPE
INSERT INTO M_INDUSTRY_TYPE (industry_type_id, industry_name_kana, industry_code, industry_name, description, display_order, active) VALUES
(1, 'ITセイゾウ', 'IT_MAN', 'IT・製造業', 'ソフトウェア開発と機械製造', 10, TRUE),
(2, 'サービスギョウ', 'SERVICE', 'サービス業', '飲食・小売・コンサルティング', 20, TRUE);

-- M_SELECTION_STATUS
INSERT INTO M_SELECTION_STATUS (status_id, status_type, status_code, status_name, status_name_kana, description, phase, next_step_available, agent_person_success, is_done, action_required, background_color, text_color, icon, active, is_customizable, is_system_defined, created_at, created_by, updated_at, updated_by, is_deleted) VALUES
(1, 'SELECTION', 'DOCUMENT_SCREENING', '書類選考中', 'ショルイセンコウチュウ', '企業側で書類を確認中', 1, TRUE, FALSE, FALSE, FALSE, '#f0e68c', '#333333', 'doc', TRUE, FALSE, TRUE, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, 1, FALSE),
(2, 'SELECTION', 'FIRST_INTERVIEW', '一次面接待ち', 'イチジメンセツマチ', '応募者と企業の間で日程調整中', 2, TRUE, FALSE, FALSE, TRUE, '#add8e6', '#333333', 'interview', TRUE, FALSE, TRUE, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, 1, FALSE),
(3, 'FINAL', 'OFFER', '内定通知済', 'ナイテイ', '内定が通知された状態', 4, TRUE, TRUE, FALSE, FALSE, '#90ee90', '#333333', 'offer', TRUE, FALSE, TRUE, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, 1, FALSE),
(4, 'FINAL', 'HIRED', '採用決定', 'サイヨウケッテイ', '入社が確定', 5, FALSE, TRUE, TRUE, FALSE, '#32cd32', '#ffffff', 'check', TRUE, FALSE, TRUE, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, 1, FALSE);

-- C_COMPANY
INSERT INTO C_COMPANY (company_id, company_name, company_name_kana, industry_type_id, postal_code, prefecture, city, address, phone_number, employee_count, business_description, document_assignments, company_description, recruitment_manager_name, recruitment_email, is_active, created_at, created_by, updated_at, updated_by, is_deleted) VALUES
(101, '株式会社サンプルテック', 'カブシキガイシャサンプルテック', 1, '100-0005', '東京都', '千代田区', '丸の内1-1-1', '03-1234-5678', 500, 'AIを活用したSaaS開発', 5, '働きやすい環境のIT企業', '佐藤 太郎', 'saiyo@sample.co.jp', TRUE, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, 1, FALSE),
(102, '未来コンサルティング合同会社', 'ミライコンサルティングゴウドウガイシャ', 2, '530-0001', '大阪府', '大阪市北区', '梅田2-2-2', '06-9876-5432', 50, '経営・DXコンサルティング', 2, '成長志向のコンサルファーム', '田中 花子', 'saiyo@mirai.com', TRUE, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, 1, FALSE);

-- C_USER
INSERT INTO C_USER (user_id, user_type, email, password_hash, full_name, full_name_kana, company_id, last_login_at, is_locked, email_verified, created_at, created_by, updated_at, updated_by, is_deleted) VALUES
(1, 'ADMIN', 'admin@sys.com', 'hashed_admin_pass', 'システム管理者', 'システムカンリシャ', NULL, CURRENT_TIMESTAMP, FALSE, TRUE, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, 1, FALSE),
(2, 'AGENT', 'agent_a@broker.com', 'hashed_agent_pass', '仲介 太郎', 'チュウカイ タロウ', NULL, CURRENT_TIMESTAMP, FALSE, TRUE, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, 1, FALSE),
(3, 'COMPANY', 'recruiter@sample.co.jp', 'hashed_company_pass', '佐藤 太郎', 'サトウ タロウ', 101, CURRENT_TIMESTAMP, FALSE, TRUE, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, 1, FALSE);

-- C_AGENT_PERSON
INSERT INTO C_AGENT_PERSON (agent_person_id, user_id, job_type_id, phone_number, department, specialization, email, is_active, created_at, created_by, updated_at, updated_by, is_deleted) VALUES
(1, 2, 1, '090-1111-2222', 'IT仲介部門', 'Web/アプリ開発エンジニア', 'agent_a@broker.com', TRUE, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, 1, FALSE);

-- C_JOB_APPLICATION_INFO
INSERT INTO C_JOB_APPLICATION_INFO (job_applicant_id, selection_status_id, mediator, name, name_kana, gender, date_of_birth, nationality, mail_address, telephone_number, postal_code, prefecture_id, address, final_academic_background, work_history, resume, others1, status, first_interview_date, number_of_experienced_companies, career_affiliation_name, career_industry, career_occupation, career_post, career_joining_date, career_retirement_date, reason_for_changing_job, most_recent_annual_income, desired_annual_income, desired_work_location, desired_industry, desired_occupation, english_proficiency, skill, qualifications_held, recommendation, free_entry_field, created_user, created_at, updated_user, updated_at) VALUES
(201, 2, '仲介 太郎', '山田 健太', 'ヤマダ ケンタ', '男性', '1990-05-15', '日本', 'yamada@seeker.com', '090-3333-4444', '150-0001', 13, '東京都渋谷区神宮前1-1-1', '大学卒', '5年間のWebエンジニア経験', 'resume_yamada.pdf', '特になし', '選考中', '2025-10-01', 1, '開発部', 'IT', 'Webエンジニア', 'メンバー', '2020-04-01', NULL, 'より成長できる環境を求めて', 600, 650, '東京都', 'IT', 'エンジニア', 'ビジネスレベル', 'Python, AWS, React', '基本情報技術者', '即戦力として期待できます。', '活発なコミュニケーションが可能', 'seeker', '2025-11-01', 'seeker', '2025-11-15');

-- C_RECRUITMENT_CONSIDERATION_LIST
INSERT INTO C_RECRUITMENT_CONSIDERATION_LIST (job_applicant_id, work_place, commission, assumed_gender, estimated_annual_income, employment_type, estimated_age, job_description, required_condition, created_user, created_at, updated_user, updated_at) VALUES
(201, '東京23区内', 200, '男性', 650, '正社員', 35, '新規プロダクトのバックエンド開発', 'Python/AWSを用いた開発経験3年以上', 'agent_a', '2025-11-05', 'agent_a', '2025-11-05');

-- K_JOB_POSTING_INFO
INSERT INTO K_JOB_POSTING_INFO (posting_id, company_id, industry_type_id, job_type_id, job_title, work_location, salary_min, salary_max, employment_type, recruiter_name, posting_start_date, posting_end_date, created_at, updated_at) VALUES
(1001, 101, 1, 1, 'リードエンジニア募集', '東京都千代田区', 700, 1000, '正社員', '佐藤 太郎', '2025-11-01', '2026-03-31', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- K_JOB_POSTING_INFO_DETAIL
INSERT INTO K_JOB_POSTING_INFO_DETAIL (job_requirement_id, posting_id, job_title, work_location, work_address, has_relocation, business_content, probation_period, probation_notes, break_time, employment_type, working_hours, overtime_work, compensation_benefits, welfare_benefits, holidays_vacation, holiday_notes, required_skills, preferred_skills, other_requirements, created_at, updated_at) VALUES
(1, 1001, 'バックエンド開発', '東京都千代田区', '丸の内1-1-1', FALSE, '新規SaaSのアーキテクチャ設計・開発', '3ヶ月', '期間中も給与変動なし', '1時間', '正社員', '10:00〜19:00', '月20時間程度', '賞与年2回、昇給年1回', '各種社会保険完備、住宅手当', '土日祝日', '年間休日120日以上', 'Python開発経験5年以上、AWS実務経験', '大規模トラフィック処理経験、React経験', '特にありません', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- K_APPLICATION_LIST
INSERT INTO K_APPLICATION_LIST (application_id, job_posting_id, job_applicant_id, agent_person_id, selection_status_id, applied_at, recommendation_comment, status_updated_at, is_active, created_at, created_by, updated_at, updated_by, is_deleted) VALUES
(1, 1001, 201, 1, 2, CURRENT_TIMESTAMP, '要件をすべて満たしており、即戦力です。', CURRENT_TIMESTAMP, TRUE, CURRENT_TIMESTAMP, 2, CURRENT_TIMESTAMP, 2, FALSE);

-- K_APPLICATION_DETAIL
INSERT INTO K_APPLICATION_DETAIL (application_detail_id, application_id, motivation, preferred_interview_datetime1, preferred_interview_datetime2, preferred_interview_datetime3, preferred_interview_location, preferred_interview_format, withdrawal_datetime, withdrawal_reason, document_screening_passed_date, first_interview_passed_date, second_interview_passed_date, final_interview_passed_date, offer_notification_date, offer_response_deadline, offer_response_date, offer_response_result, offered_annual_salary, offer_conditions_detail, expected_joining_date, salary_negotiation_comment, other_remarks, company_rating, self_pr, career_summary_file, created_at, created_by, updated_at, updated_by, is_deleted) VALUES
(1, 1, '貴社の先進的な技術開発に強く惹かれました。', '2025-12-20 10:00:00', '2025-12-25 14:00:00', NULL, 'オンライン', 'Web会議', NULL, NULL, '2025-11-20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-01', '年収は特にこだわりませんが、650万円以上を希望します。', '特になし', 4, '粘り強く課題解決に取り組めます。', 'career_summary_yamada.pdf', CURRENT_TIMESTAMP, 2, CURRENT_TIMESTAMP, 2, FALSE);

-- K_JOB_POSTING_FEE
INSERT INTO K_JOB_POSTING_FEE (job_posting_fee_id, job_posting_id, fee_value, type, payment_timing, fee_transfer_date, note, created_at, updated_at) VALUES
(1, 1001, 2000000.00, 'SUCCESS_FEE', '入社後翌月末', NULL, '想定年収の28%', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
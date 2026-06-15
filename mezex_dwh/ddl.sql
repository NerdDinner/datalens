CREATE TABLE raw_metrika (
    visit_id VARCHAR(50) PRIMARY KEY,
    client_id VARCHAR(50) NOT NULL,
    visit_datetime TIMESTAMP NOT NULL,
    utm_source VARCHAR(100),
    utm_medium VARCHAR(100),
    utm_campaign VARCHAR(100)
);

CREATE TABLE raw_backend_logs (
    log_id SERIAL PRIMARY KEY,
    log_datetime TIMESTAMP NOT NULL,
    user_guid VARCHAR(50),
    client_id VARCHAR(50),
    api_method VARCHAR(150),
    status_code INTEGER
);

CREATE TABLE raw_1c_leads (
    lead_id VARCHAR(50) PRIMARY KEY,
    user_guid VARCHAR(50),
    created_datetime TIMESTAMP NOT NULL,
    current_status VARCHAR(100),
    revenue NUMERIC(12, 2) DEFAULT 0.00
);

CREATE INDEX idx_metrika_client ON raw_metrika (client_id);

CREATE INDEX idx_backend_client ON raw_backend_logs (client_id);

CREATE INDEX idx_backend_guid ON raw_backend_logs (user_guid);

CREATE INDEX idx_1c_guid ON raw_1c_leads (user_guid);

CREATE VIEW v_funnel_analytics AS
SELECT
    m.client_id,
    m.visit_datetime,
    COALESCE(m.utm_source, 'direct') AS utm_source,
    COALESCE(m.utm_medium, 'none') AS utm_medium,
    COALESCE(m.utm_campaign, 'none') AS utm_campaign,
    b.log_datetime,
    b.api_method,
    b.status_code AS backend_status,
    c.lead_id,
    c.created_datetime AS lead_created_at,
    c.current_status AS status_1c,
    c.revenue
FROM
    raw_metrika m
    LEFT JOIN raw_backend_logs b ON m.client_id = b.client_id
    LEFT JOIN raw_1c_leads c ON b.user_guid = c.user_guid;
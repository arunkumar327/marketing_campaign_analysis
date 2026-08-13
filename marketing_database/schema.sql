Create database Marketing_Database;

Use Marketing_Database;

CREATE TABLE platforms (
    platform_id INT PRIMARY KEY,
    platform_name VARCHAR(50) NOT NULL,
    platform_type VARCHAR(30),
    currency VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audiences (
    audience_id INT PRIMARY KEY,
    audience_name VARCHAR(100),
    age_range VARCHAR(20),
    gender VARCHAR(20),
    location VARCHAR(100),
    interests VARCHAR(255),
    device_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE campaigns (
    campaign_id INT PRIMARY KEY,
    platform_id INT,
    campaign_name VARCHAR(150),
    campaign_objective VARCHAR(50),
    start_date DATE,
    end_date DATE,
    daily_budget DECIMAL(10,2),
    total_budget DECIMAL(12,2),
    campaign_status VARCHAR(20),
    target_region VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (platform_id) REFERENCES platforms(platform_id)
);

CREATE TABLE ad_groups (
    ad_group_id INT PRIMARY KEY,
    campaign_id INT,
    audience_id INT,
    ad_group_name VARCHAR(150),
    bid_strategy VARCHAR(30),
    bid_amount DECIMAL(10,2),
    status VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id),
    FOREIGN KEY (audience_id) REFERENCES audiences(audience_id)
);

CREATE TABLE ads (
    ad_id INT PRIMARY KEY,
    ad_group_id INT,
    ad_name VARCHAR(150),
    ad_type VARCHAR(50),
    headline VARCHAR(255),
    description TEXT,
    cta VARCHAR(50),
    landing_page_url VARCHAR(255),
    creative_size VARCHAR(50),
    status VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (ad_group_id) REFERENCES ad_groups(ad_group_id)
);

CREATE TABLE ad_performance (
performance_id INT PRIMARY KEY,
ad_id INT,
platform_id INT,
date DATE,

impressions INT,
clicks INT,
cost DECIMAL(10,2),

likes INT,
shares INT,
comments INT,

video_views INT,

ctr DECIMAL(6,4),
cpc DECIMAL(10,4),
cpm DECIMAL(10,4),

FOREIGN KEY (ad_id) REFERENCES ads(ad_id),
FOREIGN KEY (platform_id) REFERENCES platforms(platform_id)
);

CREATE TABLE conversions (
    conversion_id INT PRIMARY KEY,
    ad_id INT,
    conversion_date DATE,
    conversion_type VARCHAR(50),
    conversion_value DECIMAL(10 , 2 ),
    order_id VARCHAR(100),
    customer_id VARCHAR(100),
    device_type VARCHAR(50),
    attribution_model VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ad_id)
        REFERENCES ads (ad_id)
);

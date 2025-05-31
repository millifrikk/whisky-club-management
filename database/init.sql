-- Enable UUID extension for potential future use
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users Table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('admin', 'member', 'guest')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- Whiskies Table
CREATE TABLE whiskies (
    whisky_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    distillery VARCHAR(100),
    region VARCHAR(50),
    age INTEGER,
    abv DECIMAL(4,2), -- Alcohol by volume (e.g., 43.00%)
    type VARCHAR(50), -- Single Malt, Blend, etc.
    description TEXT,
    tasting_notes TEXT,
    purchase_date DATE,
    price DECIMAL(10,2), -- Price in currency
    quantity INTEGER DEFAULT 0,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ratings Table
CREATE TABLE ratings (
    rating_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    whisky_id INTEGER REFERENCES whiskies(whisky_id) ON DELETE CASCADE,
    overall_score INTEGER CHECK (overall_score >= 1 AND overall_score <= 10),
    appearance_score INTEGER CHECK (appearance_score >= 1 AND appearance_score <= 10),
    nose_score INTEGER CHECK (nose_score >= 1 AND nose_score <= 10),
    palate_score INTEGER CHECK (palate_score >= 1 AND palate_score <= 10),
    finish_score INTEGER CHECK (finish_score >= 1 AND finish_score <= 10),
    review_text TEXT,
    tasting_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Ensure one rating per user per whisky
    UNIQUE(user_id, whisky_id)
);

-- News/Events Table
CREATE TABLE posts (
    post_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    type VARCHAR(20) CHECK (type IN ('news', 'event')),
    event_date TIMESTAMP, -- For events only
    location VARCHAR(200), -- For events only
    capacity INTEGER, -- For events only
    created_by INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    published_at TIMESTAMP,
    is_published BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- RSVP Table for events
CREATE TABLE rsvps (
    rsvp_id SERIAL PRIMARY KEY,
    post_id INTEGER REFERENCES posts(post_id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'attending' CHECK (status IN ('attending', 'maybe', 'declined')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Ensure one RSVP per user per event
    UNIQUE(post_id, user_id)
);

-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role ON users(role);

CREATE INDEX idx_whiskies_region ON whiskies(region);
CREATE INDEX idx_whiskies_type ON whiskies(type);
CREATE INDEX idx_whiskies_name ON whiskies(name);
CREATE INDEX idx_whiskies_distillery ON whiskies(distillery);

CREATE INDEX idx_ratings_whisky ON ratings(whisky_id);
CREATE INDEX idx_ratings_user ON ratings(user_id);
CREATE INDEX idx_ratings_score ON ratings(overall_score);

CREATE INDEX idx_posts_type ON posts(type);
CREATE INDEX idx_posts_published ON posts(is_published);
CREATE INDEX idx_posts_date ON posts(event_date);
CREATE INDEX idx_posts_created_by ON posts(created_by);

CREATE INDEX idx_rsvps_post ON rsvps(post_id);
CREATE INDEX idx_rsvps_user ON rsvps(user_id);

-- Insert sample admin user 
-- Password: admin123 (hashed with bcrypt)
INSERT INTO users (username, email, password_hash, role) VALUES 
('admin', 'admin@abywhisky.club', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewlhBdXux0jbm.oS', 'admin'),
('johndoe', 'john@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewlhBdXux0jbm.oS', 'member'),
('whiskyexpert', 'expert@abywhisky.club', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewlhBdXux0jbm.oS', 'member');

-- Insert sample whiskies for testing
INSERT INTO whiskies (name, distillery, region, age, abv, type, description, tasting_notes, price, quantity) VALUES 
('The Macallan 18 Year Old', 'Macallan', 'Speyside', 18, 43.0, 'Single Malt', 'An exceptional single malt whisky matured for eighteen years in a combination of exceptional oak casks.', 'Rich amber color. Rich dried fruits and sherry on the nose. Complex palate with dried fruits, spice, and chocolate. Long, warm finish with dried fruit and wood smoke.', 450.00, 2),

('Lagavulin 16 Year Old', 'Lagavulin', 'Islay', 16, 43.0, 'Single Malt', 'One of the most intensely flavoured of all Scotch whiskies. The peat smoke, iodine and seaweed give way to the natural sweetness of the malt.', 'Deep amber with gold highlights. Intensely flavoured, peat smoke with iodine and seaweed, dry woody finish. Powerful peat smoke, medicinal, tar, fishing net, with a hint of sweetness.', 120.00, 3),

('Glenfiddich 12 Year Old', 'Glenfiddich', 'Speyside', 12, 40.0, 'Single Malt', 'Fresh and fruity with a hint of pear. Beautifully crafted and delicately balanced.', 'Bright gold color. Fresh pear with subtle oak on the nose. Light, fresh orchard fruits and honey on the palate. Clean, short finish with a hint of wood.', 65.00, 5),

('Ardbeg 10 Year Old', 'Ardbeg', 'Islay', 10, 46.0, 'Single Malt', 'Revered around the world as the peatiest, smokiest, most complex single malt of them all.', 'Light gold color. Heavy smoke with lime and pine resin on the nose. Powerful peat smoke, espresso, dark chocolate on the palate. Long, glorious finish with coffee and dark chocolate.', 85.00, 4),

('Highland Park 12 Year Old', 'Highland Park', 'Highland', 12, 40.0, 'Single Malt', 'The perfect balance of Orkney elements creates a whisky with the antique charm of aromatic smoke and natural sweetness.', 'Bright gold color. Aromatic smoke and heather honey on the nose. Smooth heather honey sweetness with aromatic smokiness. Medium length finish with heather, honey, and a hint of smoke.', 70.00, 3);

-- Insert sample news and events
INSERT INTO posts (title, content, type, event_date, location, capacity, created_by, published_at, is_published) VALUES 
('Welcome to Åby Whisky Club!', 'We are excited to launch our new whisky club management platform. Here you can explore our extensive collection, rate your favorite whiskies, and stay updated with club events.', 'news', NULL, NULL, NULL, 1, CURRENT_TIMESTAMP, true),

('Monthly Tasting Session - January 2025', 'Join us for our monthly whisky tasting session where we will be exploring the flavors of Speyside single malts. We will be tasting Macallan 18, Glenfiddich 12, and more!', 'event', '2025-06-15 18:00:00', 'Åby Community Center', 20, 1, CURRENT_TIMESTAMP, true),

('New Arrivals: Islay Collection', 'We have added some fantastic Islay whiskies to our collection including Lagavulin 16 and Ardbeg 10. These peated beauties are perfect for those who enjoy intense, smoky flavors.', 'news', NULL, NULL, NULL, 1, CURRENT_TIMESTAMP, true),

('Whisky and Cheese Pairing Evening', 'A special evening dedicated to the art of pairing whisky with artisanal cheeses. Learn how different flavor profiles complement each other in this guided tasting experience.', 'event', '2025-06-30 19:30:00', 'Åby Whisky Lounge', 15, 1, CURRENT_TIMESTAMP, true);

-- Insert sample ratings
INSERT INTO ratings (user_id, whisky_id, overall_score, appearance_score, nose_score, palate_score, finish_score, review_text, tasting_date) VALUES 
(2, 1, 9, 9, 9, 9, 9, 'Absolutely exceptional whisky. The 18 years of maturation really shows in the complexity and depth of flavors. Worth every penny!', '2025-05-15'),
(2, 2, 8, 8, 9, 8, 8, 'A powerhouse of peat and smoke. Not for beginners, but if you love Islay whiskies, this is a must-try. The medicinal notes are prominent but balanced.', '2025-05-20'),
(3, 1, 10, 10, 10, 10, 9, 'Simply perfection in a bottle. The sherry influence is beautifully integrated, and the finish goes on forever. My personal favorite.', '2025-05-18'),
(3, 3, 7, 7, 7, 7, 6, 'A solid everyday dram. Fresh and approachable, perfect for newcomers to single malt whisky. Good value for money.', '2025-05-22');

-- Insert sample RSVPs
INSERT INTO rsvps (post_id, user_id, status) VALUES 
(2, 2, 'attending'),
(2, 3, 'attending'),
(4, 2, 'maybe'),
(4, 3, 'attending');

-- Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for whiskies table
CREATE TRIGGER update_whiskies_updated_at BEFORE UPDATE ON whiskies 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Display success message
DO $$
BEGIN
    RAISE NOTICE 'Åby Whisky Club database initialized successfully!';
    RAISE NOTICE 'Sample data includes:';
    RAISE NOTICE '- 3 users (admin, johndoe, whiskyexpert)';
    RAISE NOTICE '- 5 whiskies from various regions';
    RAISE NOTICE '- 4 posts (2 news, 2 events)';
    RAISE NOTICE '- Sample ratings and RSVPs';
    RAISE NOTICE 'Default admin login: admin@abywhisky.club / admin123';
END $$;
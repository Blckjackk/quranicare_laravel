-- Sample seed data for ai_knowledge_base
-- Adjust IDs/content to your schema. Run in quranicare_db.

INSERT INTO ai_knowledge_base
(content_type, content_id, emotion_trigger, context_keywords, guidance_text, suggested_actions, usage_count, effectiveness_score, is_active, created_at)
VALUES
('quran_ayah', 1, 'sedih,murung', 'sabar,kesabaran,ujian,pertolongan',
 'Dalam Islam, sabar adalah kunci ketika menghadapi ujian. Allah berfirman dalam QS. Al-Baqarah:153: "Hai orang-orang yang beriman, jadikanlah sabar dan shalat sebagai penolongmu..." Mari perbanyak doa dan shalat.',
 '["Perbanyak doa","Shalat sunnah jika mampu","Istighfar dengan khusyu"]', 0, 0.00, 1, NOW()),
('quran_ayah', 2, 'cemas,takut', 'tawakal,pertolongan Allah,ketenangan',
 'Allah mencukupkan hamba yang bertawakal. QS. At-Talaq:3 mengingatkan kita untuk menyerahkan urusan kepada-Nya, karena Allah Maha Mencukupi.',
 '["Tarik napas dalam 4-4-6","Baca hasbunallah wa ni’mal wakil","Shalat dua rakaat"]', 0, 0.00, 1, NOW()),
('dzikir_doa', 10, 'murung,sedih', 'doa,ketenangan,hati',
 'Anjurkan memperbanyak dzikir La ilaha illallah dan istighfar. Dzikir melapangkan dada dan menenangkan hati.',
 '["Dzikir pagi-petang","Baca istighfar 33x","Bacalah Ayat Kursi sebelum tidur"]', 0, 0.00, 1, NOW()),
('psychology_material', 100, 'cemas,bingung', 'pernapasan,grounding,relaksasi',
 'Teknik pernapasan 4-4-6 dapat menurunkan kecemasan secara fisiologis. Lakukan secara bertahap hingga napas lebih stabil.',
 '["Tarik 4 detik","Tahan 4 detik","Hembus 6 detik","Ulang 6-10 kali"]', 0, 0.00, 1, NOW()),
('general_guidance', NULL, 'marah', 'emosi,amarah,kendali diri',
 'Dalam mengelola amarah, Rasulullah menganjurkan untuk diam, berwudhu, dan mengubah posisi (duduk/berbaring). Ini membantu menurunkan gejolak emosi.',
 '["Diam sejenak","Ambil wudhu","Ubah posisi","Beralih topik"]', 0, 0.00, 1, NOW());

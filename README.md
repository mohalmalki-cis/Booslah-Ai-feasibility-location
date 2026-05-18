

**Boosla**

*Graduation Project | King Saud University*

Boosla is a Flutter mobile app that helps entrepreneurs in Riyadh find the best location to open their business. The user enters their project details — business type (café, restaurant, grocery), target audience, budget, area, and operating preferences — and the app uses AI and a real Riyadh districts dataset to recommend the top locations and explain why.

**What the app does:**

The core feature scores every district in Riyadh across 7 factors: purchasing power, competitor quality, delivery culture, accessibility, market diversity, budget fit, and landmark proximity. It then ranks the districts and shows the user an interactive heatmap, a map pin on the best location, score breakdowns, competitor stats, a 6-month growth projection, and 4 personalised AI tips.

**The AI journey:**

The team first tried building a machine learning model from scratch using a Feed-Forward Neural Network in PyTorch, trained on the district dataset. This hit real walls — sparse data in some districts, no reliable ground-truth labels for business success, and the difficulty of deploying a locally-trained model into a live mobile app. The team pivoted to the Anthropic Claude API, which solved all three problems: it reasons over the dataset directly, explains its outputs in Arabic, and integrates into Flutter with a single HTTP call.

**Tech stack:**

Flutter (Dart), Firebase, Anthropic Claude API (`claude-haiku-4-5-20251001`), OpenStreetMap via flutter_map, CustomPainter charts, local SharedPreferences storage, and a custom Riyadh districts JSON dataset built by the team.

**What makes it valuable:**

Most people open businesses based on gut feeling or copying competitors. Boosla replaces that with real data — income levels, competitor density, audience patterns — and turns it into a clear recommendation anyone can understand, in Arabic, in under a minute.

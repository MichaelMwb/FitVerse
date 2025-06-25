import json

# Load your original exercise JSON
with open("original_exercises.json", "r") as f:
    data = json.load(f)

# Build simplified version with ID and animation defaults
cleaned_data = []
for ex in data:
    instructions = ex.get("instructions", [])
    description = "\n".join(instructions) if instructions else ""

    cleaned_data.append({
        "id": ex.get("id"),
        "name": (ex.get("name") or "").strip(),
        "equipment": (ex.get("equipment") or "").strip(),
        "primaryMuscles": ex.get("primaryMuscles", []),
        "secondaryMuscles": ex.get("secondaryMuscles", []),
        "category": (ex.get("category") or "").strip(),
        "level": (ex.get("level") or "").strip(),
        "description": description,
        "has_animation": False,
        "animation_url": None
    })

# Save your custom JSON
with open("custom_exercises.json", "w") as f:
    json.dump(cleaned_data, f, indent=2)

print(f"✅ Saved {len(cleaned_data)} exercises with ID and default animation fields.")

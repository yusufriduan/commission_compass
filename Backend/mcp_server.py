from fastmcp import FastMCP

mcp = FastMCP("CommissionCompass")

@mcp.tool()
def calculate_complexity_score(scope_description: str, category: str = "General", urgency: str = "normal") -> dict:
    """Calculates a complexity score (1-10) for any freelance task."""
    score = 5.0
    risk_factors = []
    
    # Analyze scope length
    word_count = len(scope_description.split())
    if word_count < 20:
        score += 2.0
        risk_factors.append("High Ambiguity: Scope is too short.")

    # Apply urgency penalty
    if urgency.lower() in ["high", "rush"]:
        score += 1.5
        risk_factors.append("Rush Job: Increased pressure.")

    # Industry-specific weighting
    category_modifiers = {
        "Creative": 1.1,
        "Technical": 1.3,
        "Administrative": 0.8
    }
    score *= category_modifiers.get(category, 1.0)
    
    return {
        "complexity_score": round(min(10.0, score), 2),
        "risk_factors": risk_factors or ["Standard project parameters"]
    }

@mcp.tool()
def get_market_benchmark(category: str = "General", specialization: str = "General") -> dict:
    """Returns the 2026 average hourly rate for a specific field."""
    rates = {
        "Creative": {"General": 55.0, "Motion": 90.0, "Illustration": 65.0},
        "Technical": {"General": 95.0, "AI/ML": 190.0, "Web": 80.0},
        "Writing": {"General": 45.0, "Technical": 85.0}
    }
    
    cat_data = rates.get(category, {"General": 60.0})
    hourly_rate = cat_data.get(specialization, cat_data["General"])
    
    return {
        "average_hourly": hourly_rate,
        "currency": "USD",
        "trend": "Stable"
    }

if __name__ == "__main__":
    mcp.run()
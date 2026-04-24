from fastmcp import FastMCP

mcp = FastMCP("CommissonCompass")

# Reminder to self: Update this part (At least add more specifity to the tools in mcp)

@mcp.tool()
def calculate_complexity_score(scope_description: str, technical_stack: str) -> dict:
    """Calculates a numerical complexity score (1-10) based on stack and scope."""
    complexity_map = {"C++": 1.5, "C": 1.4, "OS": 1.8, "Python": 1.0}
    
    base_complexity = 5.0
    multiplier = sum([complexity_map.get(s, 1.0) for s in technical_stack.split(",")]) / 2
    
    scope_penalty = len(scope_description.split()) / 100 
    
    final_score = min(10.0, (base_complexity * multiplier) + scope_penalty)
    
    return {
        "complexity_score": round(final_score, 2),
        "risk_factors": ["High memory management overhead" if "C++" in technical_stack else "Low risk"]
    }

@mcp.tool()
def get_market_benchmark(role: str) -> float:
    """Returns the 2026 average hourly rate for a specific role."""
    rates = {
        "Systems Engineer": 155.0,
        "Embedded Dev": 140.0,
        "Generalist": 85.0
    }
    return rates.get(role, 100.0)

if __name__ == "__main__":
    mcp.run()
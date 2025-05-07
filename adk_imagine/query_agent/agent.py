from google.adk.agents.sequential_agent import SequentialAgent
from imagine_agent.agent import imagine_agent 
from painter_agent.agent import painter_agent
from google.adk.tools import agent_tool

root_agent = SequentialAgent(
    name="root_agent",
    description="Refine user prompt for an AI image generation model.",
    sub_agents=[imagine_agent, painter_agent],
)
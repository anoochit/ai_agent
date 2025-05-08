import os
from google.adk.agents.sequential_agent import SequentialAgent
from imagine_agent.agent import imagine_agent 
from painter_agent.agent import painter_agent

from opik.integrations.adk import OpikTracer

opik_tracer = OpikTracer()

root_agent = SequentialAgent(
    name="root_agent",
    description="Refine user prompt for an AI image generation model.",
    sub_agents=[imagine_agent, painter_agent],
    before_agent_callback=opik_tracer.before_agent_callback,
    after_agent_callback=opik_tracer.after_agent_callback,
)
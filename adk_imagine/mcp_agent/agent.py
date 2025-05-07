# ./adk_agent_samples/mcp_agent/agent.py
from google.adk.agents.llm_agent import LlmAgent
from google.adk.tools.mcp_tool.mcp_toolset import MCPToolset, StdioServerParameters


async def create_agent():
  """Gets tools from MCP Server."""
  tools, exit_stack = await MCPToolset.from_server(
      connection_params=StdioServerParameters(
          command='npx',
          args=["-y",    # Arguments for the command
            "@modelcontextprotocol/server-filesystem",
            # TODO: IMPORTANT! Change the path below to an ABSOLUTE path on your system.
            "d:\\tmp",
          ],
      )
  )

  agent = LlmAgent(
      model='gemini-2.0-flash',
      name='enterprise_assistant',
      instruction=(
          'Help user accessing their file systems'
      ),
      tools=[*tools],
  )
  return agent, exit_stack

root_agent = create_agent()
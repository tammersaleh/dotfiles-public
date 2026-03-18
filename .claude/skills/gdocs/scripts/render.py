"""
Render a structured Google Doc response to Markdown.
"""


def runs_to_markdown(runs: list) -> str:
    """Convert a list of inline runs to Markdown text."""
    parts = []
    for run in runs:
        text = run['text']
        if run.get('code'):
            text = f'`{text}`'
        elif run.get('bold') and run.get('italic'):
            text = f'***{text}***'
        elif run.get('bold'):
            text = f'**{text}**'
        elif run.get('italic'):
            text = f'*{text}*'

        if run.get('url'):
            text = f'[{text}]({run["url"]})'

        parts.append(text)
    return ''.join(parts)


def elements_to_markdown(elements: list) -> str:
    """Convert structured document elements to Markdown."""
    lines = []

    for el in elements:
        t = el['type']

        if t == 'heading':
            level = el.get('level', 1)
            if level == 0:
                level = 1
            prefix = '#' * level
            lines.append(f'{prefix} {runs_to_markdown(el["runs"])}')

        elif t == 'paragraph':
            lines.append(runs_to_markdown(el['runs']))

        elif t == 'list_item':
            indent = '  ' * el.get('nesting', 0)
            marker = '1.' if el.get('ordered') else '-'
            lines.append(f'{indent}{marker} {runs_to_markdown(el["runs"])}')

        elif t == 'horizontal_rule':
            lines.append('---')

        elif t == 'table':
            rows = el.get('rows', [])
            if rows:
                lines.append('| ' + ' | '.join(rows[0]) + ' |')
                lines.append('| ' + ' | '.join('---' for _ in rows[0]) + ' |')
                for row in rows[1:]:
                    lines.append('| ' + ' | '.join(row) + ' |')

    return '\n'.join(lines)


def doc_response_to_markdown(result: dict) -> str:
    """Convert a full document API response to a Markdown string."""
    parts = [f'# {result["title"]}', '']
    parts.append(elements_to_markdown(result.get('elements', [])))
    return '\n'.join(parts)

library highlight;

import 'dart:async';
import 'dart:html';
import 'dart:js';

JsObject hljs = context['hljs'];

String highlight(String code) {
  return hljs.callMethod('highlight', ['scheme', code, true])['value'];
}

Future highlightAtEnd(Element input, String code) async {
  input.innerHtml = highlight(code);
  await new Future.delayed(const Duration(milliseconds: 0));
  var selection = window.getSelection();
  var range = new Range();
  range.selectNodeContents(input);
  range.collapse(false);
  selection.removeAllRanges();
  selection.addRange(range);
}

Future highlightSaveCursor(Element input) async {
  String text = input.text;
  Selection selection = window.getSelection();
  Range last = selection.getRangeAt(0);
  int position = findPosition(input, last);
  String styled = highlight(text);
  input.innerHtml = styled;
  Range range = _makeRange(input, position);
  selection.removeAllRanges();
  selection.addRange(range);
}

int findPosition(Element input, Range range) {
  int offset = range.startOffset;
  Node needle = range.startContainer;
  while (needle.hasChildNodes()) {
    needle = needle.lastChild;
    offset = needle.text.length;
  }
  bool found = false;
  int countUntil(Node current) {
    if (current == needle) {
      found = true;
      return 0;
    } else if (current.nodeType == Node.TEXT_NODE) {
      return current.text.length;
    } else {
      int total = 0;
      for (Node child in current.childNodes) {
        total += countUntil(child);
        if (found) return total;
      }
      return total;
    }
  }

  return countUntil(input) + offset;
}

Range _makeRange(Element input, int remaining) {
  Node findNode(Node current) {
    if (current.nodeType == Node.TEXT_NODE) {
      int length = current.text.length;
      if (length >= remaining) {
        return current;
      }
      remaining -= length;
      return null;
    }
    for (Node child in current.childNodes) {
      Node result = findNode(child);
      if (result != null) return result;
    }
    return null;
  }

  Node node = findNode(input);
  Range range = new Range();
  if (node == null) {
    range.selectNodeContents(input);
    range.collapse(false);
  } else {
    range.setStart(node, remaining);
    range.setEnd(node, remaining);
  }
  return range;
}

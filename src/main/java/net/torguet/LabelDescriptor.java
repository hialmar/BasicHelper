package net.torguet;

import java.util.ArrayList;

public record LabelDescriptor(ArrayList<String> multiLine, int lineNumberInMultiLine, int globalLineNumber) {
}

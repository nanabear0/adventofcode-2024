package save.santa.day21;

import org.javatuples.Pair;

import java.io.IOException;
import java.math.BigInteger;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.time.Instant;
import java.util.*;

public class Main {

    public static List<String> permutation(String str) {
        List<String> permutations = new ArrayList<>();
        permutation("", str, permutations);
        return permutations;
    }

    private static void permutation(String prefix, String str, List<String> list) {
        int n = str.length();
        if (n == 0) list.add(prefix);
        else {
            for (int i = 0; i < n; i++)
                permutation(prefix + str.charAt(i), str.substring(0, i) + str.substring(i + 1, n), list);
        }
    }

    public static HashMap<Character, Pair<Integer, Integer>> fillNumberGrid() {
        HashMap<Character, Pair<Integer, Integer>> numberGrid = new HashMap<>();
        numberGrid.put('7', new Pair<>(0, 0));
        numberGrid.put('8', new Pair<>(1, 0));
        numberGrid.put('9', new Pair<>(2, 0));
        numberGrid.put('4', new Pair<>(0, 1));
        numberGrid.put('5', new Pair<>(1, 1));
        numberGrid.put('6', new Pair<>(2, 1));
        numberGrid.put('1', new Pair<>(0, 2));
        numberGrid.put('2', new Pair<>(1, 2));
        numberGrid.put('3', new Pair<>(2, 2));
        numberGrid.put('0', new Pair<>(1, 3));
        numberGrid.put('A', new Pair<>(2, 3));

        return numberGrid;
    }

    public static HashMap<Character, Pair<Integer, Integer>> fillInputGrid() {
        HashMap<Character, Pair<Integer, Integer>> inputGrid = new HashMap<>();
        inputGrid.put('^', new Pair<>(1, 0));
        inputGrid.put('A', new Pair<>(2, 0));
        inputGrid.put('<', new Pair<>(0, 1));
        inputGrid.put('v', new Pair<>(1, 1));
        inputGrid.put('>', new Pair<>(2, 1));

        return inputGrid;
    }


    public static Set<String> possiblePaths(char start, char end, HashMap<Character, Pair<Integer, Integer>> grid, boolean isNumber, Set<String> oldPaths) {
        Set<String> paths = new HashSet<>();
        var p1 = grid.get(start);
        var p2 = grid.get(end);
        var moveY = p2.getValue1() - p1.getValue1();
        var moveX = p2.getValue0() - p1.getValue0();
        var pathEdge1 = new Pair<>(p1.getValue0(), p2.getValue1());
        var pathEdge2 = new Pair<>(p2.getValue0(), p1.getValue1());
        var invalidPoint = isNumber ? new Pair<>(0, 3) : new Pair<>(0, 0);
        var absMoveX = Math.abs(moveX);
        var absMoveY = Math.abs(moveY);
        var path1valid = !pathEdge1.equals(invalidPoint);
        var path2valid = !pathEdge2.equals(invalidPoint);
        var hMove = (moveX > 0 ? ">" : "<").repeat(absMoveX);
        var vMove = (moveY > 0 ? "v" : "^").repeat(absMoveY);
        String invalidMove;
        if (path1valid && path2valid) {
            invalidMove = null;
        } else {
            if (isNumber) {
                if (moveX < 0) {
                    invalidMove = hMove + vMove;
                } else {
                    invalidMove = vMove + hMove;
                }
            } else {
                if (moveX < 0) {
                    invalidMove = hMove + vMove;
                } else {
                    invalidMove = vMove + hMove;
                }
            }
        }
        var permutations = permutation(hMove + vMove).stream().filter(p -> !p.equals(invalidMove)).toList();

        for (var oldPath : oldPaths) {
            for (var perm : permutations) {
                paths.add(oldPath + perm + 'A');
            }
        }
        return paths;
    }


    public static Set<String> getPossiblePaths(String subCommand, int level, HashMap<Character, Pair<Integer, Integer>> numberGrid, HashMap<Character, Pair<Integer, Integer>> inputGrid) {
        Set<String> subPaths = new HashSet<>();
        subPaths.add("");
        subPaths = possiblePaths('A', subCommand.charAt(0), (level == 0) ? numberGrid : inputGrid, level == 0, subPaths);
        for (int i = 1; i < subCommand.length(); i++) {
            subPaths = possiblePaths(subCommand.charAt(i - 1), subCommand.charAt(i), (level == 0) ? numberGrid : inputGrid, level == 0, subPaths);
        }
        return subPaths;
    }

    public static Map<String, BigInteger> splitCommandsFromA(String path) {
        var calcPath = path;
        Map<String, BigInteger> subCommands = new HashMap<>();

        do {
            int aIndex = calcPath.indexOf('A');
            String subStr = calcPath.substring(0, aIndex + 1);
            var oldValue = subCommands.getOrDefault(subStr, BigInteger.ZERO);
            subCommands.put(subStr, oldValue.add(BigInteger.ONE));
            calcPath = calcPath.substring(aIndex + 1);
        } while (!calcPath.isEmpty());

        return subCommands;
    }

    public static BigInteger bestPath(String path, int level, int targetLevel, HashMap<Character, Pair<Integer, Integer>> numberGrid, HashMap<Character, Pair<Integer, Integer>> inputGrid, Map<Integer, HashMap<String, BigInteger>> bestPathCache, Map<String, String> getBestPossiblePathCache) {
        if (!bestPathCache.containsKey(level)) bestPathCache.put(level, new HashMap<>());
        var levelCache = bestPathCache.get(level);
        BigInteger result = splitCommandsFromA(path).entrySet().stream().map(subCommandEntry -> {
            var subCommand = subCommandEntry.getKey();
            BigInteger subCommandCount = subCommandEntry.getValue();
            if (targetLevel == level) {
                levelCache.put(subCommand, BigInteger.valueOf(subCommand.length()));
                return subCommandCount.multiply(BigInteger.valueOf(subCommand.length()));
            }
            if (levelCache.containsKey(subCommand)) return levelCache.get(subCommand).multiply(subCommandCount);
            var cost = getPossiblePaths(subCommand, level, numberGrid, inputGrid)
                    .stream()
                    .map(subPath -> bestPath(subPath, level + 1, targetLevel, numberGrid, inputGrid, bestPathCache, getBestPossiblePathCache))
                    .min(BigInteger::compareTo)
                    .orElseThrow();
            levelCache.put(subCommand, cost);
            return cost.multiply(subCommandCount);
        }).reduce(BigInteger::add).orElseThrow();
        levelCache.put(path, result);
        return result;
    }

    public static void main(String[] args) throws IOException {
        Instant start = Instant.now();
        URL resource = save.santa.day21.Main.class.getClassLoader().getResource("day21-input.txt");
        assert resource != null;
        var numberGrid = fillNumberGrid();
        var inputGrid = fillInputGrid();
        Map<Integer, HashMap<String, BigInteger>> bestPathCache = new HashMap<>();
        Map<String, String> getBestPossiblePathCache = new HashMap<>();
        int hiddenLayers = 25;
        var result = Files.lines(Path.of(resource.getFile())).map(line -> {
            var cost = bestPath(line, 0, hiddenLayers + 1, numberGrid, inputGrid, bestPathCache, getBestPossiblePathCache);
            System.out.println(line + ": " + cost);
            return new BigInteger(line.substring(0, line.length() - 1)).multiply(cost);
        }).reduce(BigInteger::add).orElseThrow();
        System.out.println("part1: " + result);
        Instant end = Instant.now();

        System.out.println("Time: " + Duration.between(start, end).toMillis() + "ms");
    }
}
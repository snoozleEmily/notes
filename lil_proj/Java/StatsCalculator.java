import java.util.*;
import java.util.stream.Collectors;

public class StatsCalculator {

    public static void main(String[] args) {
        try (Scanner scanner = new Scanner(System.in)) {
            System.out.println("Enter numbers separated by spaces:");
            String input = scanner.nextLine().trim();
            
            if (input.isEmpty()) {
                System.out.println("Error: No input provided");
                return;
            }

            List<Double> numbers = Arrays.stream(input.split("\\s+"))
                    .filter(s -> !s.isEmpty())
                    .map(StatsCalculator::safeParseDouble)
                    .filter(Objects::nonNull)
                    .collect(Collectors.toList());

            if (numbers.isEmpty()) {
                System.out.println("Error: No valid numbers entered");
                return;
            }

            Collections.sort(numbers);
            
            double mean = calculateMean(numbers);
            List<Double> mode = calculateMode(numbers);
            double stdDev = calculateStandardDeviation(numbers, mean);
            
            // Calculate percentiles
            double p0 = numbers.get(0);                 // Minimum (0th percentile)
            double p25 = calculatePercentile(numbers, 0.25);
            double p50 = calculatePercentile(numbers, 0.50);  // Same as median
            double p75 = calculatePercentile(numbers, 0.75);
            double p100 = numbers.get(numbers.size() - 1);  // Maximum (100th percentile)

            System.out.println("-------");
            System.out.printf("""
                    Basic Statistics:
                    Mean: %.2f
                    Mode: %s
                    Standard Deviation: %.2f
                    
                    Percentiles:
                    p0 (min): %.2f
                    p25: %.2f
                    p50 (median): %.2f
                    p75: %.2f
                    p100 (max): %.2f%n""",
                    mean, (mode.isEmpty() ? "No mode" : mode), stdDev,
                    p0, p25, p50, p75, p100);
        }
    }

    /**
     * Calculates the specified percentile using linear interpolation
     * @param numbers Sorted list of numbers
     * @param percentile Value between 0 and 1 (e.g., 0.25 for 25th percentile)
     * @return interpolated percentile value
     */
    private static double calculatePercentile(List<Double> numbers, double percentile) {
        if (percentile < 0 || percentile > 1) {
            throw new IllegalArgumentException("Percentile must be between 0 and 1");
        }
        
        // Using R's type 7 interpolation method
        double index = percentile * (numbers.size() - 1);
        int lower = (int) Math.floor(index);
        int upper = (int) Math.ceil(index);
        
        if (lower == upper) {
            return numbers.get(lower);
        }
        
        // Linear interpolation between adjacent points
        double weight = index - lower;
        return numbers.get(lower) * (1 - weight) + numbers.get(upper) * weight;
    }

    private static Double safeParseDouble(String s) {
        try {
            return Double.parseDouble(s);
        } catch (NumberFormatException e) {
            System.out.println("Warning: Skipping invalid input '" + s + "'");
            return null;
        }
    }

    private static double calculateMean(List<Double> numbers) {
        return numbers.stream()
                .mapToDouble(Double::doubleValue)
                .sum() / numbers.size();
    }

    private static List<Double> calculateMode(List<Double> numbers) {
        Map<Double, Integer> freqMap = new HashMap<>();
        int maxFreq = 0;
        
        // Build frequency map while tracking maximum frequency
        for (double num : numbers) {
            int newFreq = freqMap.merge(num, 1, Integer::sum);
            if (newFreq > maxFreq) maxFreq = newFreq;
        }
        
        if (maxFreq == 1) return Collections.emptyList();

        // Final variable for lambda compatibility
        final int modeFrequency = maxFreq;
        
        return freqMap.entrySet().stream()
                .filter(entry -> entry.getValue() == modeFrequency)
                .map(Map.Entry::getKey)
                .sorted()
                .collect(Collectors.toList());
    }

    private static double calculateStandardDeviation(List<Double> numbers, double mean) {
        double sumSquares = numbers.stream()
                .mapToDouble(num -> Math.pow(num - mean, 2))
                .sum();
        return Math.sqrt(sumSquares / numbers.size());
    }
}
import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        try {
            connection = DriverManager.getConnection(url, username, password);
        } catch (SQLException ex) {
            System.out.println("Failed to find the JDBC driver");
            return false;
        }
        return true;
    }

    @Override
    public boolean disconnectDB() {
        try {
            connection.close();
        } catch(SQLException ex) {
            System.err.println("SQL Error:" + ex.getMessage());
            return false;
        }
        return true;
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        List<Integer> elections = new ArrayList<Integer>();
        List<Integer> cabinets = new ArrayList<Integer>();

        String statement = "SELECT election.id AS eid, cabinet.id AS cid " +
                            "FROM country, election, cabinet " +
                            "WHERE country.id = election.country_id AND " +
                            "cabinet.election_id = election.id AND " +
                            "country.name = ? " +
                            "ORDER BY election.e_date DESC";
        try {
             PreparedStatement prepState = connection.prepareStatement(statement);
             prepState.setString(1, countryName);

             ResultSet queryResult;
             queryResult = prepState.executeQuery();
              while(queryResult.next()) {
                  int election = queryResult.getInt(1);
                  int cabinet = queryResult.getInt(2);
                  if (!elections.contains(election)) {
                      elections.add(election);
                  }
                  if (!cabinets.contains(cabinet)) {
                      cabinets.add(cabinet);
                  }
              }
        } catch (SQLException ex) {
            System.err.println("SQL Error:" + ex.getMessage());
            return null;
        }

        ElectionCabinetResult ECresults = new ElectionCabinetResult(elections, cabinets);
        return ECresults;
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        List<Integer> politicians = new ArrayList<Integer>();
        try {
            String queryString = "SELECT P1.description AS desc1, P1.comment AS com1, "
                                    +"P2.id AS pid2, P2.description AS desc2, P2.comment AS com2 "
                                 +"FROM politician_president AS P1, politician_president AS P2 "
                                 +"WHERE P1.id = ? AND P1.id < P2.id;";
            PreparedStatement prepState = connection.prepareStatement(queryString);
            prepState.setInt(1, politicianName);
            ResultSet queryResult;
            queryResult = prepState.executeQuery();
            while (queryResult.next()) {
                Integer pid2 = queryResult.getInt("pid2");
                String desc1 = queryResult.getString("desc1");
                String desc2 = queryResult.getString("desc2");
                String com1 = queryResult.getString("com1");
                String com2 = queryResult.getString("com2");
                double similarness = similarity(desc1.concat(com1),desc2.concat(com2));
                if (similarness >= threshold) {
                    politicians.add(pid2);
                }
            }

        } catch(SQLException ex) {
            System.err.println("SQL Error:" + ex.getMessage());
        }
        return politicians;
    }

    public static void main(String[] args) {
        /*
        try {
            Assignment2 a2 = new Assignment2();
            a2.connectDB("jdbc:postgresql://localhost:5432/csc343h-lazaroel?currentSchema=parlgov",
                            "lazaroel", "");
             You can put testing code in here. It will not affect our autotester.
            System.out.println(a2.electionSequence("Japan").toString());
            System.out.println(a2.findSimilarPoliticians(9, Float.valueOf("0.25")));
            System.out.println("Hello");
        } catch (ClassNotFoundException ex) {
            System.out.println(ex.getMessage());
        } */
    }

}


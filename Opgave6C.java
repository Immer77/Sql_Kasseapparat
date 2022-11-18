package JDBC22Y;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.*;

public class Opgave6C {

    public static void main(String[] args) {

        try {

            BufferedReader inLine = new BufferedReader(new InputStreamReader(System.in));
            System.out.println("Indtast Amount");
            String amount = inLine.readLine();
            System.out.print("Indtast fixedPrice: ");
            String fixedPrice = inLine.readLine();
            System.out.println("Intast Salgsnummer: ");
            String salgsNummer = inLine.readLine();
            System.out.println("Indtast priceId: ");
            String priceId = inLine.readLine();

            Connection minConnection;
            minConnection = DriverManager.getConnection(
                    "jdbc:sqlserver://DESKTOP-C9CSAU4\\SQLExpress;databaseName=KasseApparatDatabase;user=sa;password=;");

            String sql = "insert into Orderline values(?,?,?,?)";// preparedStatement
            PreparedStatement prestmt = minConnection.prepareStatement(sql);
            prestmt.clearParameters();

            prestmt.setInt(1, Integer.parseInt(amount.trim()));
			if(fixedPrice.isBlank() || Double.parseDouble(fixedPrice.trim()) <= 0){
				prestmt.setString(2,null);
			}else{
				prestmt.setDouble(2, Double.parseDouble(fixedPrice.trim()));
			}

            prestmt.setInt(3, Integer.parseInt(salgsNummer.trim()));
            prestmt.setInt(4, Integer.parseInt(priceId.trim()));

            prestmt.executeUpdate();
            System.out.println("Orderline indsat");

            Statement stmt = minConnection.createStatement();

            ResultSet res = stmt.executeQuery("select Price.priceid, Product.currentamount, Product.minimiumamount from Product " +
					"inner join Price " +
					"on Product.productNr = Price.productNr where Price.priceid = " + Double.parseDouble(priceId.trim()));


			while (res.next()){
				if (Double.parseDouble(res.getString(2)) < Double.parseDouble(res.getString(3))) {
					System.out.println("Den nuværende mængde er kommet under minimumsmængden");
				}
			}

            if (prestmt != null)
                prestmt.close();
            if (minConnection != null)
                minConnection.close();

        } catch (SQLException sqlException) {
            System.out.println("Besked: " + sqlException.getMessage());
            System.out.println("Kode: " + sqlException.getErrorCode());

            if (sqlException.getErrorCode() == 2627) {
                System.out.println("SalgsID eksisterer allerede");
            }
            if (sqlException.getErrorCode() == 8152) {
                System.out.println("Du skal have et kortere navn");
            }
			if(sqlException.getErrorCode() == 207){
				System.out.println("Kollonne navnet findes ikke");
			}
        } catch (IOException sqE) {
            System.out.println("fejl:  " + sqE.getMessage());
        }

    }

}
